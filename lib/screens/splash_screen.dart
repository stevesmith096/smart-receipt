import 'package:agora/utils/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:splash_screen_view/SplashScreenView.dart';
import 'photo_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return SplashScreenView(
      navigateRoute: PhotoPage(),
      duration: 5000,
      imageSize: 600,
      imageSrc: "assets/images/SmartReceiptLogo.gif",
      text: "Smart Receipt",
      textType: TextType.ColorizeAnimationText,
      textStyle: TextStyle(fontSize: 30.0),
      colors: [ColorConstant.primaryColor, Colors.green, Colors.grey],
      backgroundColor: Colors.white,
    );
  }
}

// <div>Icons made by <a href="https://www.freepik.com" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a></div>
