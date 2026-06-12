import 'package:test/test.dart';
import 'package:e_shop_api/e_shop_api.dart';


/// tests for AuthApi
void main() {
  final instance = EShopApi().getAuthApi();

  group(AuthApi, () {
    // Request OTP via phone
    //
    //Future v1AuthRequestOtpPost(V1AuthRequestOtpPostRequest v1AuthRequestOtpPostRequest) async
    test('test v1AuthRequestOtpPost', () async {
      // TODO
    });

    // Verify OTP and receive JWT
    //
    //Future v1AuthVerifyOtpPost(V1AuthVerifyOtpPostRequest v1AuthVerifyOtpPostRequest) async
    test('test v1AuthVerifyOtpPost', () async {
      // TODO
    });

  });
}
