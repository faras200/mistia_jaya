import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pos_app/core/constants/colors.dart';

class MyLoading {
  Future<void> loading(BuildContext context) async {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.threeBounce
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 40.0
      ..radius = 10.0
      ..backgroundColor = AppColors.primary
      ..indicatorColor = AppColors.white
      ..textColor = AppColors.white
      ..maskType = EasyLoadingMaskType.black
      ..userInteractions = false
      ..dismissOnTap = false;

    return EasyLoading.show(status: 'loading...');
  }

  void dismiss() {
    EasyLoading.dismiss();
  }
}
