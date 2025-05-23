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
      imageSize: 200,
      imageSrc: "assets/bill.png",
      text: "The simple solution to splitting bills",
      textType: TextType.ColorizeAnimationText,
      textStyle: TextStyle(
        fontSize: 30.0,
      ),
      colors: [
        Colors.red,
        Colors.purple,
        Colors.blue,
        Colors.green,
      ],
      backgroundColor: Colors.white,
    );
  }
}

// <div>Icons made by <a href="https://www.freepik.com" title="Freepik">Freepik</a> from <a href="https://www.flaticon.com/" title="Flaticon">www.flaticon.com</a></div>
