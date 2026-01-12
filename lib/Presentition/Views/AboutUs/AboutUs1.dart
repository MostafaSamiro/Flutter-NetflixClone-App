
import 'package:flutter/material.dart';
import 'package:netflix_clone/Presentition/Widgets/BuildSmoothNavigates.dart';
import 'package:sizer/sizer.dart' show SizerExt;

import 'AbouUs2.dart';
class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: Color(0xff121312),
      body:
      Stack(
        children: [
          Container(
              height: double.infinity,
              child: Image.asset("assets/images/Movies Posters Group.png",fit: BoxFit.cover,)
          ),
              Column(mainAxisAlignment:MainAxisAlignment.end,
                children: [
                  Container(
                    height: 38.h,
                    decoration: BoxDecoration( gradient: LinearGradient(begin:Alignment.topCenter,end: Alignment.bottomCenter,
                        colors: [Color(0x001E1E1E00),Color(0xff121312),Color(0x91121312),Color(0xff121312)]
                    )),
                    child: Column(mainAxisAlignment:MainAxisAlignment.end,
                      children: [
                        Text('Find Your Next\nFavorite Movie Here',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                        SizedBox(height: 5,),
                        Text('Get access to a huge library of movies to suit all tastes. You will surely like it.',
                          style: TextStyle(
                              color: Colors.white60,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,),
                        SizedBox(height: 24,),
                        ElevatedButton(onPressed: (){
                          navigateWithTransitionPush(context, SecondScreen());
                        },
                            child: Text('Explore Now',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.white),),
                        style:ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffe50913),
                          padding: EdgeInsets.symmetric(horizontal: 139,vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        )
                        ),
                  SizedBox(height: 50,)

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
