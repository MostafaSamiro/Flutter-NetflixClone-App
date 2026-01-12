import 'package:flutter/material.dart';
import 'package:netflix_clone/Presentition/Widgets/BuildSmoothNavigates.dart';
import 'package:sizer/sizer.dart';

import '../AuthScreens/LoginScreen.dart';

class SecondScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body:  Stack(
      children: [

        Container(
          decoration: BoxDecoration(
            color: Color(0xff084250)
          ),
            height: double.infinity,
            child: Image.asset("assets/images/a8c73981364e3d0cf59c2d39a783a625ed5aa2b9.jpg",fit: BoxFit.cover,)
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x00084250),
                Color(0xff084250)
              ],
            ),
          ),
        ),
        Column(mainAxisAlignment:MainAxisAlignment.end,
          children: [
            Container(
              height: 70.sp,
              decoration: BoxDecoration(color: Color(0xff121312),
                borderRadius: BorderRadius.only(topRight: Radius.circular(40),topLeft:Radius.circular(40))
              ),
              child: Column(mainAxisAlignment:MainAxisAlignment.center,
                children: [
                  SizedBox(height:0.h,),
                  Text('Discover Movies',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,),
                  SizedBox(height: 1.h,),
                  Text('Explore a vast collection of movies in all qualities and genres. Find your next favorite film with ease.',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,),
                  SizedBox(height: 24,),
                  ElevatedButton(onPressed: (){
                    navigateWithTransitionPush(context, Login());
                  },
                      child: Text('Next',
                        style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.white),),
                      style:ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffe50913),
                        padding: EdgeInsets.symmetric(horizontal: 30.w,vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      )
                  ),

                ],
              ),
            ),
          ],
        )
      ],
    ),
    );
  }
}
