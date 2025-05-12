import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../../../../utils/Widget/Mainlayout.dart';
import '../controllers/landing_page_controller.dart';

class LandingPageView extends GetView<LandingPageController> {
  const LandingPageView({super.key});
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Center(
        child: Container(
          width: MediaQuery.sizeOf(context).width * 0.4,
          height: MediaQuery.sizeOf(context).width * 0.4,
          decoration: BoxDecoration(
            color: Color(0xFFFEFAE0),
            borderRadius: BorderRadius.circular(20.0),
          ),
        )
      ),
    );
  }
}
