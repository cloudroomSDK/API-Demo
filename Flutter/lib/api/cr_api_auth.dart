import 'dart:convert';

import '/api/cr_api.dart';
import '/implements/cr_impl.dart';
import '/implements/cr_impl_auth.dart';
import '/cr_defines.dart';

extension CrAuthApi on CrSDK {
  // 登录
  Future<CrLoginResult> login(CrLoginDat loginDat) async {
    final String loginDatJson = json.encode(loginDat.toJson());
    Map data = await CrImpl.instance.login(loginDatJson);
    final String userID = data["userID"] ?? "";
    final String cookie = data["cookie"] ?? "";
    final int sdkErr = data["sdkErr"] ?? 0;
    CrLoginResult result =
        CrLoginResult(userID: userID, cookie: cookie, sdkErr: sdkErr);
    return result;
  }

  // 登出
  Future<void> logout() async {
    return await CrImpl.instance.logout();
  }
}
