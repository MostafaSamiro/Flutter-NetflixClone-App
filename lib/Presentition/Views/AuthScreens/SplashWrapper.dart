import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Provider/AuthProvider.dart';
import '../AboutUs/AboutUs1.dart';
import '../SelectAccounts/SelectAccountScreen.dart';
import 'LoginScreen.dart';

class SplashNavigationWrapper extends StatefulWidget {
  const SplashNavigationWrapper({Key? key}) : super(key: key);

  @override
  State<SplashNavigationWrapper> createState() => _SplashNavigationWrapperState();
}

class _SplashNavigationWrapperState extends State<SplashNavigationWrapper> {
  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    final authProvider = Provider.of<AuthFireBase>(context, listen: false);

    final isLoggedIn = await authProvider.isUserLoggedIn();

    await Future.delayed(const Duration(milliseconds: 100));

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProfileSelectionScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FirstScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xffe50913),
        ),
      ),
    );
  }
}