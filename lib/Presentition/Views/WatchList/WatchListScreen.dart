import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:sizer/sizer.dart';

import '../Home/MoviesDesciption.dart';

class WatchList extends StatelessWidget {
  const WatchList({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xff151515),
        body: Center(
          child: Text(
            'Please log in to view your watchlist',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xff151515),
      appBar: AppBar(
        backgroundColor: const Color(0xff151515),
        leading: InkWell(onTap: (){
          Navigator.pop(context);
        },child: Icon(Icons.arrow_back_ios,color: Colors.white,)),

        title: const Text(
          'My List',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .collection('My List')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.red,
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading watchlist',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie_outlined,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your watchlist is empty',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add movies to see them here',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // Get the movie data
          final movies = snapshot.data!.docs;

          return Column(
            children: [
              const SizedBox(height: 20),
              // Carousel Slider - Wrapped with GestureDetector for tap handling
              Stack(
                children: [
                  FanCarouselImageSlider.sliderType1(
                    imagesLink: movies.map<String>((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final movieImage = data['movieImage'] ?? '';
                      if (movieImage.startsWith('http')) {
                        return movieImage;
                      } else {
                        return "https://image.tmdb.org/t/p/w500$movieImage";
                      }
                    }).toList(),
                    imageFitMode: BoxFit.cover,
                    isAssets: false,
                    autoPlay: true,
                    sliderHeight: 60.h,
                    sliderWidth: 100.w,
                    expandFitAndZoomable: false,
                    isClickable: false,
                    autoPlayInterval: const Duration(seconds: 5),
                    currentItemShadow: [
                      BoxShadow(
                        color: const Color(0xffe50913).withOpacity(0.5),
                        blurRadius: 5,
                        spreadRadius: 5,
                      )
                    ],
                    slideViewportFraction: 0.85,
                    showIndicator: true,
                    indicatorActiveColor: const Color(0xffd90c1a),
                    indicatorDeactiveColor: Colors.white.withOpacity(0.5),
                  ),
                  // Invisible tap detector overlay
                ],
              ),
              const SizedBox(height: 20),
              // Movie count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Icon(Icons.movie, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${movies.length} ${movies.length == 1 ? "Movie" : "Movies"} in your list',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // List view of movies
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: movies.length,
                  itemBuilder: (context, index) {
                    final movieDoc = movies[index];
                    final data = movieDoc.data() as Map<String, dynamic>;
                    final movieImage = data['movieImage'] ?? '';
                    final fullImageUrl = movieImage.startsWith('http')
                        ? movieImage
                        : "https://image.tmdb.org/t/p/w342$movieImage";

                    return Dismissible(
                      key: Key(movieDoc.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      onDismissed: (direction) {
                        // Delete from Firebase
                        FirebaseFirestore.instance
                            .collection('user')
                            .doc(user.uid)
                            .collection('My List')
                            .doc(movieDoc.id)
                            .delete();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${data['movieName']} removed from list'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoviesDescriptions(
                                realseYear: data['movieYearRealse'],
                                name: data['movieName'] ?? 'Unknown',
                                desciprtion: data['movieDescription'] ?? 'No description available',
                                rating: (data['movieRating'] ?? 0.0).toDouble(),
                                poster: data['movieImage'] ?? '',
                                language: data['movieLanguage'] ?? 'en',
                                isAdult: data['isAdult'] ?? false,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 15),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xff1f1f1f),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Movie Poster
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  fullImageUrl,
                                  width: 80,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 80,
                                      height: 120,
                                      color: Colors.grey,
                                      child: const Icon(Icons.error, color: Colors.white),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 15),
                              // Movie Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['movieName'] ?? 'Unknown',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${data['movieRating']?.toStringAsFixed(1) ?? 'N/A'}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        if (data['isAdult'] == true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              '18+',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      data['movieDescription'] ?? 'No description',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.6),
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Arrow Icon
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white54,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}