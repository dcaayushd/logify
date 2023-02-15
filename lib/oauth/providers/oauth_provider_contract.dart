import 'package:logify/oauth/models/oauth_user.dart';
import 'package:logify/oauth/models/result.dart';

enum OauthType { facebook, google, apple }

extension OauthTypeValue on OauthType {
  String value() => toString().split('.').last;

  static OauthType fromString(String value) {
    return OauthType.values.firstWhere((e) => e.value() == value);
  }
}

abstract class IOauthProvider {
  Future<Result<OAuthUser>> login();
  Future<bool> logout();
}
