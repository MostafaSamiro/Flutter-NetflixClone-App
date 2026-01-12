import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:netflix_clone/Presentition/Widgets/BuildTexts.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../DataModels/MoviesDataModel.dart';
import '../../Widgets/BuildSmoothNavigates.dart';
import 'MoviesDesciption.dart';

class AllMovies extends StatefulWidget {
  List<MoviesModel> movies;
  AllMovies({super.key, required this.movies});

  @override
  State<AllMovies> createState() => _AllMoviesState();
}

class _AllMoviesState extends State<AllMovies> {
  String selectedSort = "Suggested";
  List<MoviesModel> filteredMovies = [];

  @override
  void initState() {
    super.initState();
    filteredMovies = widget.movies;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;





  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                buildTexts("Sort by", Colors.white, 18.sp, FontWeight.bold),
                SizedBox(height: 2.h),

                _buildSortOption("Suggested", Icons.star_outline),
                _buildSortOption("Year (Newest First)", Icons.calendar_today),
                _buildSortOption("Year (Oldest First)", Icons.calendar_today_outlined),
                _buildSortOption("A-Z", Icons.sort_by_alpha),
                _buildSortOption("Z-A", Icons.sort_by_alpha),
                _buildSortOption("Rating (High to Low)", Icons.star),
                _buildSortOption("Rating (Low to High)", Icons.star_border),
                _buildSortOption("Popularity", Icons.trending_up),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String title, IconData icon) {
    bool isSelected = selectedSort == title;
    return InkWell(
      onTap: () {
        setState(() {
          selectedSort = title;
          _applySorting(title);
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h, horizontal: 2.w),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.red : Colors.grey, size: 20.sp),
            SizedBox(width: 3.w),
            Expanded(
              child: buildTexts(
                title,
                isSelected ? Colors.white : Colors.grey[400]!,
                15.sp,
                isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Icon(Icons.check, color: Colors.red, size: 20.sp),
          ],
        ),
      ),
    );
  }

  void _applySorting(String sortType) {
    setState(() {
      switch (sortType) {
        case "Year (Newest First)":
          filteredMovies.sort((a, b) => b.firstAirDate.compareTo(a.firstAirDate));
          break;
        case "Year (Oldest First)":
          filteredMovies.sort((a, b) => a.firstAirDate.compareTo(b.firstAirDate));
          break;
        case "A-Z":
          filteredMovies.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
          break;
        case "Z-A":
          filteredMovies.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
          break;
        case "Rating (High to Low)":
          filteredMovies.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
          break;
        case "Rating (Low to High)":
          filteredMovies.sort((a, b) => a.voteAverage.compareTo(b.voteAverage));
          break;
        case "Popularity":
          filteredMovies.sort((a, b) => b.popularity.compareTo(a.popularity));
          break;
        default:
          filteredMovies = List.from(widget.movies);
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 4.h),
            Row(
              children: [
                SizedBox(width: 2.w),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 5.w),
                buildTexts("Popular Shows", Colors.white, 17.sp, FontWeight.bold)
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                SizedBox(width: 2.w),
                buildTexts("Sort by", Colors.grey, 15.sp, FontWeight.bold),
              ],
            ),
            InkWell(
              onTap: _showSortBottomSheet,
              child: Row(
                children: [
                  SizedBox(width: 2.w),
                  buildTexts(selectedSort, Colors.white, 17.sp, FontWeight.bold),
                  Icon(
                    Icons.arrow_drop_down_outlined,
                    color: Colors.white,
                    size: 18.sp,
                  )
                ],
              ),
            ),
            SizedBox(
              height: 80.h,
              child: ListView.builder(
                itemCount: filteredMovies.length,
                itemBuilder: (ctx, i) {
                  return Padding(
                    padding: EdgeInsets.only(top: 2.h, left: 2.w),
                    child: InkWell(
                      onTap: (){
                        navigateWithTransitionPush(context,MoviesDescriptions(
                          realseYear: filteredMovies[i].firstAirDate,
                          name: filteredMovies[i].name,
                          desciprtion:filteredMovies[i].overview ,
                          poster: filteredMovies[i].posterPath,
                          language: filteredMovies[i].originalLanguage,
                          rating: filteredMovies[i].voteAverage,
                          isAdult:filteredMovies[i].adult ,


                        ));
                      },
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w342${filteredMovies[i].posterPath}',
                              width: 35.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Expanded(
                            child: buildTexts(
                              filteredMovies[i].name,
                              Colors.white,
                              15.sp,
                              FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          InkWell(
                            onTap: (){
                              addToWatchList(
                                movieName: filteredMovies[i].name,
                                movieImage: filteredMovies[i].posterPath,
                                movieDescription: filteredMovies[i].overview,
                                movieLang: filteredMovies[i].originalLanguage,
                                isAdult: filteredMovies[i].adult,
                                movieRating: filteredMovies[i].voteAverage,
                                context: context,
                                year: filteredMovies[i].firstAirDate
                              );

                            },
                            child: Column(
                              children: [
                                Icon(Icons.add ,color: Colors.white,size: 19.sp,),
                                buildTexts("My List", Colors.red, 16.sp, FontWeight.bold)
                              ],
                            ),
                          ),
                          SizedBox(width: 2.w),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

}

Future<void> addToWatchList({
  required String movieName,
  required String movieImage,
  required String movieDescription,
  required String movieLang,
  required bool isAdult,
  required double movieRating,
  required BuildContext context,
  required String year
}) async {
  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const NetflixLoadingDialog(),
  );

  // Save to Firebase
  bool success = await _saveWatchList(
    movieName,
    movieImage,
    movieDescription,
    movieLang,
    isAdult,
    movieRating,
    context,
      year
  );

  // Close loading dialog
  if (context.mounted) {
    Navigator.pop(context);
  }

  // Show result dialog
  if (context.mounted) {
    showDialog(
      context: context,
      builder: (context) => NetflixResultDialog(success: success),
    );
  }
}

// Firebase save function
Future<bool> _saveWatchList(
    String movieName,
    String movieImage,
    String movieDescription,
    String movieLang,
    bool isAdult,
    double movieRating,
    BuildContext context,
    String year
    ) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(user.uid)
          .collection("My List")
          .doc(movieName)
          .set({
        'movieName': movieName,
        'movieImage': movieImage,
        'movieDescription': movieDescription,
        'movieLanguage': movieLang,
        'isAdult': isAdult,
        'movieRating': movieRating,
        'movieYearRealse':year,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true; // Success
    }
    return false; // No user
  } catch (e) {
    print('Error saving the movie: $e');
    return false; // Failed
  }
}
class NetflixLoadingDialog extends StatelessWidget {
  const NetflixLoadingDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xff1f1f1f),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              strokeWidth: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              'Adding to My List...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NetflixResultDialog extends StatelessWidget {
  final bool success;

  const NetflixResultDialog({Key? key, required this.success}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xff1f1f1f),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: success ? Colors.green : Colors.red,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: success ? Colors.green : Colors.red,
              size: 60,
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              success ? 'Success!' : 'Failed!',
              style: TextStyle(
                color: success ? Colors.green : Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            // Message
            Text(
              success
                  ? 'Movie added to your list successfully'
                  : 'Failed to add movie. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}