import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:logify/oauth/models/oauth_user.dart';
import 'package:logify/oauth/models/result.dart';
import 'package:logify/oauth/providers/google_auth.dart';
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements Client {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Fake implements GoogleSignInAccount {
  @override
  String get email => 'email';

  @override
  String get id => 'id';

  @override
  String get photoUrl => 'photoUrl';
  @override
  Future<Map<String, String>> get authHeaders => Future.value(
      <String, String>{'Authorization': 'Bearer 123', 'X-Goog_AuthUser': '0'});

  @override
  int get hashCode => Object.hash(email, id, photoUrl);
}

void main() {
  late GoogleAuthProvider sut;
  late MockClient client;
  late MockGoogleSignIn googleSignIn;

  setUp(() {
    client = MockClient();
    googleSignIn = MockGoogleSignIn();
    sut = GoogleAuthProvider(
      client: client,
      googleSignIn: googleSignIn,
    );
  });

  setUpAll(() {
    registerFallbackValue(Uri());
  });

  group('GoogleAuthProvider', () {
    test('Should return errors when google doesn\'t return a valid account',
        () async {
      when(() => googleSignIn.signIn()).thenAnswer((_) async => null);

      final Result<OAuthUser> result = await sut.login();
      expect(result.failure, true);
    });

    test('Should return errors when google server throws error', () async {
      when(() => googleSignIn.signIn())
          .thenThrow(Exception('failed to sign in'));

      final Result<OAuthUser> result = await sut.login();
      expect(result.failure, true);
    });

    test('Should return errors when people api falls to return user profile',
        () async {
      when(() => googleSignIn.signIn())
          .thenAnswer((_) async => MockGoogleSignInAccount());
      when(() => googleSignIn.disconnect()).thenAnswer((_) async => null);
      when(() => googleSignIn.isSignedIn()).thenAnswer((_) async => false);
      when(() => client.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => Response('', 400));

      final Result<OAuthUser> result = await sut.login();

      expect(result.failure, true);
    });

    test('Should return user when google authentication is successful',
        () async {
      when(() => googleSignIn.signIn())
          .thenAnswer((_) async => MockGoogleSignInAccount());
      when(() => client.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => Response(jsonEncode(_googleProfile()), 200));

      final Result<OAuthUser> result = await sut.login();

      expect(result.success, true);
      expect(result.value!.email, 'useremail@gmail.com');
    });
  });
}

Map<String, dynamic> _googleProfile() => <String, dynamic>{
      'names': [
        {
          'displayName': 'Person',
          'familyName': 'Name',
          'givenName': 'Person',
          'displayNameLastFirst': 'Name, Person',
          'unstructuredName': 'Person Name'
        }
      ],
      'emailAddresses': [
        {
          'value': 'useremail@gmail.com',
        }
      ],
      'phoneNumbers': [
        {
          'canonicalForm': '+18768678944',
          'type': 'mobile',
          'formattedType': 'Mobile',
        }
      ]
    };
