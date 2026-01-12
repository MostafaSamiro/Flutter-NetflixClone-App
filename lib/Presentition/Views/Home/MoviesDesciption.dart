import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:netflix_clone/Presentition/Widgets/BuildTexts.dart';
import 'package:sizer/sizer.dart';
import '../../Widgets/BuildSmoothNavigates.dart';
import '../WatchList/WatchListScreen.dart';
import 'AllMovies.dart';

class MoviesDescriptions extends StatelessWidget {

  final String realseYear , name , desciprtion,poster,language;
  final double rating;
  final bool isAdult;
  MoviesDescriptions({super.key ,required this.realseYear,required this.name,required this.desciprtion,required this.rating,required this.poster,required this.language,required this.isAdult, });


  static const String netflixSvg = ''' 
  <svg width="496" height="171" viewBox="0 0 496 171" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M469.466 81.3958L496 171C488.18 169.576 480.365 167.791 472.407 166.184L457.46 116.674L442.102 162.097C434.564 160.489 427.159 159.954 419.621 158.705L446.57 80.3305L422.127 0H444.751L458.433 44.8819L473.099 0H495.996L469.466 81.3958ZM404.263 0H383.734V155.325C390.437 155.861 397.417 156.214 404.263 157.28V0ZM365.999 153.541C347.29 151.939 328.575 150.52 309.446 149.979V0.000688161H330.39V124.687C342.401 125.041 354.408 126.284 365.999 126.996V153.541ZM287.099 60.7447V87.4606H258.474V148.2H237.812V0H296.461V26.7158H258.479V60.7454H287.104L287.099 60.7447ZM202.618 26.7158V149.625C195.634 149.625 188.517 149.625 181.671 149.979V26.7158H160.026V0H224.397V26.7158H202.618ZM137.406 88.8803C128.192 88.8803 117.298 88.8803 109.478 89.4218V129.139C121.766 128.068 134.055 126.825 146.481 126.289V151.939L88.5344 157.822V0H146.477V26.7158H109.477V62.6998C117.579 62.6998 130.006 62.1644 137.405 62.1644V88.8858L137.406 88.8803ZM21.3596 73.9175V167.255C13.8258 168.326 7.11842 169.575 0 171V0H19.9699L47.1968 97.0831V0H68.1448V159.954C60.7448 161.561 53.2023 162.097 45.2439 163.516L21.3596 73.9175Z" fill="#E50914"/>
</svg>

  
  ''';

  static const String line = ''' 
  <svg width="3" height="64" viewBox="0 0 3 64" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M2.69922 0H0V63.9869H2.69922V0Z" fill="#FCFCFC" stroke="#FCFCFC" stroke-width="0.000639869"/>
</svg>

  
  ''';
  @override
  Widget build(BuildContext context) {
    final year = DateTime.parse(realseYear).year.toString();
    int filledStars = (rating / 2).round();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: ClipRRect(

                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50)
                ),
                child: Image.network(
                  'https://image.tmdb.org/t/p/w342${poster}',
                  width: 100.w,
                  height: 500,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            SizedBox(height: 2.h,),

            SizedBox(height: 1.h,),
            buildTexts(name, Colors.white, 20, FontWeight.bold),
            SizedBox(height: 1.h,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              buildTexts(year, Colors.grey, 17, FontWeight.bold),
                SizedBox(width: 1.w,),
                SvgPicture.string(line,height: 3.h,),
                SizedBox(width: 2.w,),

              isAdult == false ? Container(
                width: 30,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2)
                ),
                child: Center(child: buildTexts("+18", Colors.white, 15, FontWeight.bold)),
              ):Container(),
                SizedBox(width: 2.w,),

                SvgPicture.string(line,height: 3.h,),
              SizedBox(width: 2.w,),

              Container(
                width: 30,
                height: 22,
                decoration: BoxDecoration(
                    border: Border.all(color:Colors.grey.withOpacity(0.5),width: 0.5.w),
                    borderRadius: BorderRadius.circular(2)
                ),
                child: Center(child: buildTexts("HD", Colors.white, 15, FontWeight.bold)),
              ),
                SizedBox(width: 2.w,),

                SvgPicture.string(line,height: 3.h,),
              SizedBox(width: 2.w,),

              buildTexts(language, Colors.grey, 17, FontWeight.bold),






            ],),
            SizedBox(height: 1.h,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  index < filledStars ? Icons.star : Icons.star_border,
                  color: CupertinoColors.systemYellow,
                  size: 5.w,
                );
              }),
            ),

            SizedBox(height: 3.h,),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [


                InkWell(
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final docSnapshot = await FirebaseFirestore.instance
                          .collection('user')
                          .doc(user.uid)
                          .collection('My List')
                          .doc(name)
                          .get();

                      if (docSnapshot.exists) {
                        showAlreadyInListDialogAnimated(context, name);
                      } else {

                        addToWatchList(
                            movieName: name,
                            movieImage: poster,
                            movieDescription: desciprtion,
                            movieLang: language,
                            isAdult: isAdult,
                            movieRating: rating,
                            context: context,
                            year:realseYear
                        );
                      }
                    }
                  },



                  child: Column(
                    children: [
                      Icon(Icons.add,color: Colors.white,size: 20.sp,),
                      buildTexts("My List ", Colors.white, 15, FontWeight.normal)

                    ],
                  ),
                ),
                SvgPicture.string(netflixSvg,height: 3.h,),
                Column(
                  children: [
                    Icon(Icons.info_outline,color: Colors.white,size: 20.sp,),
                    buildTexts("Info", Colors.white, 15, FontWeight.normal)

                  ],
                ),



              ],
            ),
            SizedBox(height: 2.h,),

            Padding(
              padding:  EdgeInsets.only(left:4.w),
              child: Row(
                children: [
                  Expanded(child: buildTexts(desciprtion, Colors.white, 16, FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(height: 10.h,)




          ],
        ),
      ),
    );
  }
  void showAlreadyInListDialogAnimated(BuildContext context, String movieName) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Already in List',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color(0xff1f1f1f),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Icon
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Title
                  const Text(
                    'Already Added!',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Message
                  Text(
                    '"$movieName" is already in your watchlist.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white54, width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            'Close',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            navigateWithTransitionPush(context, WatchList());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          child: const Text(
                            'View List',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

}
