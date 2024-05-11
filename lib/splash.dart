import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AnimatedSplashScreen(
            duration: 2500,
            splash: Stack(
              children: [
                Image.asset(
                  'assets/images/707002.gif',
                  // استبدل هذا بالمسار الصحيح للصورة
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                const Center(
                  child: Text(
                    "Water quality",
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.blueGrey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            nextScreen: LoginScreen(),
            splashTransition: SplashTransition.fadeTransition,
            pageTransitionType: PageTransitionType.bottomToTop,
            backgroundColor: Colors.white)
    );
  }
}