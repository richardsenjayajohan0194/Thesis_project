import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/db_services_controller.dart';

import '../../../../utils/Widget/Inputfield.dart';
import '../../../../utils/Widget/Mainlayout.dart';

import '../controllers/login_controller.dart';

final _formKey = GlobalKey<FormState>();

class LoginView extends GetView<LoginController> {
  LoginView({super.key});

  final firestore = Get.find<DbServicesController>();

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        child: Stack(
        children: <Widget>[
          Image.asset("images/image 3.png"),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
                color: const Color(0xFFFEFAE0),
              ),
              height: MediaQuery.of(context).size.height * 0.5,
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(30, 40, 30, 0),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Login",
                        style: TextStyle(
                          fontFamily: 'Livvic',
                          fontSize: MediaQuery.of(context).size.height * 0.03,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA6B37D),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      Column(
                        children: [
                          Row(
                            children: [
                              Image.asset("images/vektor_user.png"),
                              SizedBox(width: MediaQuery.of(context).size.width * 0.03),
                              Expanded(
                                child: Inputfield(
                                  controller: controller.username,
                                  hintText: 'Username',
                                  isObscuredText: true,
                                  useOutlineBorder: true,
                                  contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Image.asset("images/vektor_password.png"),
                              SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                              Expanded(
                                child: Inputfield(
                                  controller: controller.password,
                                  hintText: 'Password',
                                  isObscuredText: false,
                                  useOutlineBorder: true,
                                  contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                          ElevatedButton(
                            onPressed: () {
                              _formKey.currentState!.validate();
                              firestore.checkUser(controller.username.text, controller.password.text);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Color(0xFFA6B37D),
                              minimumSize: Size(MediaQuery.of(context).size.width * 0.25, MediaQuery.of(context).size.height * 0.05),
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize: MediaQuery.of(context).size.height * 0.025,
                              ),
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                          RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Did't have an account? ",
                                  style: TextStyle(
                                    fontFamily: "Livvic",
                                    fontSize: MediaQuery.of(context).size.height * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC0C78C),
                                  ),
                                ),
                                TextSpan(
                                  text : ' Register',
                                  style: TextStyle(
                                    fontFamily: "Livvic",
                                    color: Color(0xFFA6B37D),
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    fontSize: MediaQuery.of(context).size.height * 0.02,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}