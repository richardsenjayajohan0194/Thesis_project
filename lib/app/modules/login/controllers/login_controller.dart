import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  //TODO: Implement LoginController

  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();


  @override
  void onClose() {
    username.dispose();
    password.dispose();
    super.onClose();
  }


}
