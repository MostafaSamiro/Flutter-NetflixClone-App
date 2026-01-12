import 'package:flutter/cupertino.dart';
import 'package:sizer/sizer.dart';

Widget buildTexts (String text , Color color , double fontSize , FontWeight weight){
  return Text(
      text,
    style: TextStyle(
      fontWeight: weight ,
      fontSize: fontSize.sp,
      color: color
    ),
  );

}