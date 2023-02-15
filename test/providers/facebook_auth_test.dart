import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logify/oauth/models/oauth_user.dart';
import 'package:logify/oauth/models/result.dart';
import 'package:logify/oauth/providers/facebook_auth.dart';
import 'package:mocktail/mocktail.dart';

class MockFacebookAuth extends Mock implements FacebookAuth {}

void main() {
  late FacebookAuthProvider sut;
  late MockFacebookAuth mockFacebookAuth;

  setUp(() {
    mockFacebookAuth = MockFacebookAuth();
    sut = FacebookAuthProvider(facebookAuth: mockFacebookAuth);
  });

  group('FacebookAuthProvider.login', () {
    test('should return errors when facebook login failed', () async {
      when(() => mockFacebookAuth.login()).thenAnswer(
        (_) async => LoginResult(status: LoginStatus.failed),
      );

      final Result<OAuthUser> result = await sut.login();

      expect(result.failure, true);
    });

    test('should return errors when server fails while fetching user data',
        () async {
      when(() => mockFacebookAuth.login()).thenAnswer(
        (_) async => LoginResult(status: LoginStatus.success),
      );
      when(
        () => mockFacebookAuth.getUserData(fields: any(named: 'fields')),
      ).thenThrow(Exception('failed to sign in'));

      when(() => mockFacebookAuth.logOut())
          .thenAnswer((_) => Future<void>.value());

      final Result<OAuthUser> result = await sut.login();

      expect(result.failure, true);
    });

    test('should return user when facebook authentication is successful',
        () async {
      when(() => mockFacebookAuth.login()).thenAnswer(
        (_) async => LoginResult(status: LoginStatus.success),
      );
      when(
        () => mockFacebookAuth.getUserData(fields: any(named: 'fields')),
      ).thenAnswer((_) => Future.value(_facebookProfile()));

      final Result<OAuthUser> result = await sut.login();

      expect(result.success, true);
      expect(result.value!.email, 'useremail@gmail.com');
    });
  });
}

Map<String, dynamic> _facebookProfile() => <String, dynamic>{
      'email': 'useremail@gmail.com',
      'id': 3003332493073668,
      'first_name': 'first_name',
      'last_name': 'last_name',
      'picture': {
        'data': {
          'height': 50,
          'is_silhouette': 0,
          'url': 'url',
          'width': 50,
        },
      }
    };