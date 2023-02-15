import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/oauth_user.dart';
import '../models/result.dart';
import 'oauth_provider_contract.dart';

class FacebookAuthProvider implements IOauthProvider {
  final FacebookAuth _facebookAuth;

  FacebookAuthProvider({FacebookAuth? facebookAuth})
      : _facebookAuth = facebookAuth ?? FacebookAuth.instance;

  @override
  Future<Result<OAuthUser>> login() async {
    final LoginResult result = await _facebookAuth.login();
    if (result.status != LoginStatus.success) {
      return Result<OAuthUser>.failure(['failed to sign in']);
    }

    return await _fetchUser();
  }

  @override
  Future<bool> logout() async {
    try {
      await _facebookAuth.logOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Result<OAuthUser>> _fetchUser() async {
    try {
      final userData = await _facebookAuth.getUserData(
        fields: "first_name,last_name, email,picture.width(200)",
      );
      final String? photoUrl = userData['picture'] != null
          ? userData['picture']['data']['url'].toString()
          : null;

      final OAuthUser user = OAuthUser(
        firstName: userData['first_name'].toString(),
        lastName: userData['last_name'].toString(),
        email: userData['email'].toString(),
        photoUrl: photoUrl,
      );
      return Result<OAuthUser>.success(user);
    } catch (e) {
      return Result<OAuthUser>.failure(['failed to sign in']);
    }
  }
}