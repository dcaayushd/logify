import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:logify/oauth/models/result.dart';
import 'package:logify/oauth/models/oauth_user.dart';
import 'package:logify/oauth/providers/oauth_provider_contract.dart';

class GoogleAuthProvider implements IOauthProvider {
  final GoogleSignIn _googleSignIn;
  final Client client;

  GoogleAuthProvider({
    required this.client,
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ??
            GoogleSignIn(scopes: [
              'email',
              'profile',
            ]);

  @override
  Future<Result<OAuthUser>> login() async {
    final GoogleSignInAccount? googleSignInAccount = await _handleSignIn();
    if (googleSignInAccount == null) {
      return Result<OAuthUser>.failure(<String>['Google sign in failed']);
    }

    final Result<OAuthUser> userInfo =
        await _fetchUserInfo(googleSignInAccount);
    if (userInfo.failure) {
      logout();
    }
    return userInfo;
  }

  @override
  Future<bool> logout() async {
    await _googleSignIn.disconnect();
    return await _googleSignIn.isSignedIn() ? false : true;
  }

  Future<GoogleSignInAccount?> _handleSignIn() async {
    GoogleSignInAccount? currentUser;
    try {
      currentUser = await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
    return currentUser;
  }

  Future<Result<OAuthUser>> _fetchUserInfo(
      GoogleSignInAccount currentUser) async {
    final Map<String, String> header = await currentUser.authHeaders;
    final Response result = await client.get(
      Uri.parse(
          'https://people.googleapis.com/me?personFields=names, emailAddresses, phoneNumbers'),
      headers: {
        'Authorization': header['Authorization']!,
      },
    );
    if (result.statusCode != 200) {
      return Result<OAuthUser>.failure(<String>['Google sign in failed']);
    }
    final data = jsonDecode(result.body);
    // final data = json.decode(result.body);
    String? phoneNumber = data['phoneNumbers'] != null
        ? data['phoneNumbers'][0]['canonicalForm'].toString()
        : null;

    final OAuthUser user = OAuthUser(
      firstName: data['names'][0]['givenName'] as String,
      lastName: data['names'][0]['familyName'] as String,
      email: data['emailAddresses'][0]['value'] as String,
      photoUrl: currentUser.photoUrl,
      phoneNumber: phoneNumber,
    );

    return Result<OAuthUser>.success(user);
  }
}
