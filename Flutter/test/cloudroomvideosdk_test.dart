import 'package:cloudroomvideosdk/api/cr_api.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloudroomvideosdk/cloudroomvideosdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('cloudroomvideosdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await CrSDK.instance.getVersion(), '42');
  });
}
