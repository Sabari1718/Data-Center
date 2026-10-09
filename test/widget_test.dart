import 'package:flutter_test/flutter_test.dart';
import 'package:data_center/core/constants/app_constants.dart';

void main() {
  test('App constants sanity test', () {
    expect(AppConstants.appName, 'Data Center');
    expect(AppConstants.defaultUserName, 'lohit');
  });
}
