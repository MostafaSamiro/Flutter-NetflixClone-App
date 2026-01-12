import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../DataModels/MoviesDataModel.dart';
import '../Home/MoviesDesciption.dart';

class NetflixSearchDelegate extends SearchDelegate<String> {
  final List<MoviesModel> allMovies;

  NetflixSearchDelegate({required this.allMovies});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 16.sp,
        ),
        border: InputBorder.none,
      ),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 18.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  @override
  String get searchFieldLabel => 'Search movies, shows...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        AnimatedOpacity(
          opacity: query.isNotEmpty ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              query = '';
              showSuggestions(context);
            },
          ),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
        color: Colors.white,
      ),
      onPressed: () => close(context, ''),
    );
  }


  String _getMovieTitle(MoviesModel movie) {
    return movie.name.isNotEmpty ? movie.name : movie.originalName;
  }

  String _getPosterPath(MoviesModel movie) {
    return movie.posterPath;
  }

  String _getMovieId(MoviesModel movie) {
    return movie.name.replaceAll(' ', '_');
  }


  @override
  Widget buildResults(BuildContext context) {
    final results = allMovies.where((movie) {
      final title = _getMovieTitle(movie).toLowerCase();
      final searchLower = query.toLowerCase();
      return title.contains(searchLower);
    }).toList();

    return _buildResultsBody(context, results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return _buildEmptyState(context);
    }

    final suggestions = allMovies.where((movie) {
      final title = _getMovieTitle(movie).toLowerCase();
      final searchLower = query.toLowerCase();
      return title.contains(searchLower);
    }).toList();

    return _buildResultsBody(context, suggestions);
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Icon(
                      Icons.search,
                      size: 80.sp,
                      color: Colors.grey[700],
                    ),
                  );
                },
              ),
              SizedBox(height: 2.h),
              Text(
                'Search for movies and shows',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 4.h),
              _buildTopSearches(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSearches(BuildContext context) {
    final topSearches = allMovies.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Top Searches',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        ...topSearches.asMap().entries.map((entry) {
          final index = entry.key;
          final movie = entry.value;
          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 100)),
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: _buildTopSearchItem(context, movie),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTopSearchItem(BuildContext context, MoviesModel movie) {
    final posterPath = _getPosterPath(movie);
    final title = _getMovieTitle(movie);

    return InkWell(
      onTap: () {
        query = title;
        showResults(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: posterPath.isNotEmpty
                  ? Image.network(
                "https://image.tmdb.org/t/p/w200$posterPath",
                width: 20.w,
                height: 6.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 20.w,
                    height: 6.h,
                    color: Colors.grey[800],
                    child: Icon(Icons.movie, color: Colors.grey[600]),
                  );
                },
              )
                  : Container(
                width: 20.w,
                height: 6.h,
                color: Colors.grey[800],
                child: Icon(Icons.movie, color: Colors.grey[600]),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.play_circle_outline,
              color: Colors.white,
              size: 28.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsBody(BuildContext context, List<MoviesModel> results) {
    if (results.isEmpty) {
      return _buildNoResults(context);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: GridView.builder(
        padding: EdgeInsets.all(3.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 2.w,
          mainAxisSpacing: 1.h,
        ),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final movie = results[index];
          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 30)),
            curve: Curves.easeOutCubic,
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: _buildMovieCard(context, movie),
          );
        },
      ),
    );
  }

  Widget _buildMovieCard(BuildContext context, MoviesModel movie) {
    final posterPath = _getPosterPath(movie);
    final title = _getMovieTitle(movie);
    final movieId = _getMovieId(movie);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MoviesDescriptions(
              realseYear: movie.firstAirDate,
              name: movie.name,
              desciprtion: movie.overview,
              rating: movie.voteAverage,
              poster: movie.posterPath,
              language: movie.originalLanguage,
              isAdult: movie.adult,
            ),
          ),
        );
      },
      child: Hero(
        tag: 'movie_$movieId',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xffe50913).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              fit: StackFit.expand,
              children: [
                posterPath.isNotEmpty
                    ? Image.network(
                  "https://image.tmdb.org/t/p/w500$posterPath",
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: Center(
                        child: Icon(
                          Icons.movie,
                          color: Colors.grey[600],
                          size: 40.sp,
                        ),
                      ),
                    );
                  },
                )
                    : Container(
                  color: Colors.grey[800],
                  child: Center(
                    child: Icon(
                      Icons.movie,
                      color: Colors.grey[600],
                      size: 40.sp,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 1.h,
                  left: 1.w,
                  right: 1.w,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          offset: const Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              builder: (context, double value, child) {
                return Transform.scale(
                  scale: 0.8 + (value * 0.2),
                  child: Opacity(
                    opacity: value,
                    child: Icon(
                      Icons.search_off,
                      size: 80.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 2.h),
            Text(
              'No results found for "$query"',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Try different keywords',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}