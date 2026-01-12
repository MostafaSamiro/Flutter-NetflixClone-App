import 'package:flutter/material.dart';
void navigateWithTransitionPush(BuildContext context, Widget page) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var beginOffset = Offset(1.0, 0.0);
        var endOffset = Offset.zero;
        var curve = Curves.easeInOut;
        var tween = Tween(begin: beginOffset, end: endOffset)
            .chain(CurveTween(curve: curve));
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    ),
  );
}
void navigateWithTransitionPushReplacment(BuildContext context, Widget page) {
  Navigator.pushReplacement(
    context,
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var beginOffset = Offset(1.0, 0.0);
        var endOffset = Offset.zero;
        var curve = Curves.easeInOut;
        var tween = Tween(begin: beginOffset, end: endOffset)
            .chain(CurveTween(curve: curve));
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    ),
  );
}
void navigateWithTransitionPushAndRemoveUntil(
    BuildContext context,
    Widget page,
    ) {
  Navigator.pushAndRemoveUntil(
    context,
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var beginOffset = Offset(1.0, 0.0);
        var endOffset = Offset.zero;
        var curve = Curves.easeInOut;
        var tween = Tween(begin: beginOffset, end: endOffset)
            .chain(CurveTween(curve: curve));
        var fadeTween = Tween<double>(begin: 0.0, end: 1.0);
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
    ),
        (Route<dynamic> route) => false,
  );
}