import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:netflix_clone/Presentition/Widgets/BuildTexts.dart';
import 'package:sizer/sizer.dart';

Widget buildSelectedAccountContainer (String image , name){
  return Column(
    children: [
      Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(width: 1.w,color: Color(0xff1f1f1f )),
          image: DecorationImage(image: AssetImage(image),fit: BoxFit.cover)

        ),
      ),
      buildTexts(name, Colors.white, 15, FontWeight.bold)
    ],
  );
}