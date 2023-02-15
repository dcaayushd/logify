import 'package:flutter_test/flutter_test.dart';
import 'package:logify/oauth/models/oauth_user.dart';
import 'package:logify/oauth/models/result.dart';
import 'package:logify/oauth/providers/apple_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class StaticMethodsWrapper {
  Future<bool> isAvailable() async => true;
  Future<AuthorizationCredentialAppleID> getCredentials(
          {required List<AppleIDAuthorizationScopes> scopes,
          String? nonce}) async =>
      // ignore: null_argument_to_non_null_type
      Future.value();
}

class MockStaticMethodsWrapper extends Mock implements StaticMethodsWrapper {}

void main() {
  late AppleAuthProvider sut;
  late MockStaticMethodsWrapper mocks;

  setUp(() {
    mocks = MockStaticMethodsWrapper();
    sut = AppleAuthProvider(
      isAvailable: mocks.isAvailable,
      signInWithApple: (String nonce) =>
          mocks.getCredentials(scopes: [], nonce: nonce),
    );
  });

  group('AppleAuthProvider.login', () {
    test('should return errors when apple sign in is not available', () async {
      when(() => mocks.isAvailable()).thenAnswer(
        (_) async => false,
      );

      final Result<OAuthUser> result = await sut.login();

      expect(result.failure, true);
    });

    test('should return errors when apple server throws error', () async {
      when(() => mocks.isAvailable()).thenAnswer(
        (_) async => true,
      );
      when(
        () => mocks.getCredentials(
            scopes: any(named: 'scopes'), nonce: any(named: 'nonce')),
      ).thenThrow(Exception('failed to sign in'));

      final Result<OAuthUser> result = await sut.login();

      expect(result.failure, true);
    });

    test('should return user when apple authentication is successful',
        () async {
      when(() => mocks.isAvailable()).thenAnswer(
        (_) async => true,
      );
      when(
        () => mocks.getCredentials(
            scopes: any(named: 'scopes'), nonce: any(named: 'nonce')),
      ).thenAnswer((_) async => const AuthorizationCredentialAppleID(
          authorizationCode: '200',
          email: 'useremail@gmail.com',
          familyName: 'last_name',
          givenName: 'first_name',
          identityToken: '',
          state: '',
          userIdentifier: ''));

      final Result<OAuthUser> result = await sut.login();

      expect(result.success, true);
      expect(result.value!.email, 'useremail@gmail.com');
    });
  });
}