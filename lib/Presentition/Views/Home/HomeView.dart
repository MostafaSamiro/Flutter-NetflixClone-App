import 'dart:convert';

import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:flow_drawer/flow_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:netflix_clone/Presentition/Widgets/BuildSmoothNavigates.dart';
import 'package:netflix_clone/Presentition/Widgets/BuildTexts.dart';
import 'package:sizer/sizer.dart' show SizerExt;

import '../../../DataModels/MoviesDataModel.dart';
import '../Profile/ProfileView.dart';
import '../SearchingMovies/Search.dart';
import '../WatchList/WatchListScreen.dart';
import 'AllMovies.dart';
import 'MoviesDesciption.dart';


class NetflixStyleHome extends StatefulWidget {
  const NetflixStyleHome({Key? key}) : super(key: key);

  @override
  State<NetflixStyleHome> createState() => _NetflixStyleHomeState();
}

class _NetflixStyleHomeState extends State<NetflixStyleHome> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  late Future<void> future;
  late Color _randomStartColor;

  late AnimationController _glassyController;
  late Animation<double> _glassyAnimation;

  @override
  void initState() {
    super.initState();

    _glassyController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _glassyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _glassyController, curve: Curves.easeInOut),
    );

    future = fetchMovies().then((_) {
      final shuffled = List<MoviesModel>.from(allMovies)..shuffle();
      randomCarouselMovies = shuffled.take(10).toList();

      for (int i = 0; i < randomCarouselMovies.length; i++) {
        precacheImage(
          NetworkImage("https://image.tmdb.org/t/p/w500${randomCarouselMovies[i].posterPath}"),
          context,
        );
      }
    });


    final List<Color> availableColors = [
      Colors.black.withOpacity(0.92),
      Colors.grey.shade900.withOpacity(0.88),
      Color(0xff1a1a1a).withOpacity(0.90),
    ];
    _randomStartColor = (availableColors..shuffle()).first;

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _glassyController.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    const maxScroll = 200.0;
    double opacity = (_scrollOffset / maxScroll).clamp(0.0, 1.0);
    const endColor = Color(0xFF000000);
    return Color.lerp(_randomStartColor, endColor, opacity)!;
  }

  List<Color> _getGlassyGradientColors() {
    return [
      Colors.black.withOpacity(0.85 + _glassyAnimation.value * 0.1),
      Colors.grey.shade900.withOpacity(0.80 + _glassyAnimation.value * 0.12),
      Colors.black.withOpacity(0.88 + _glassyAnimation.value * 0.08),
    ];
  }

  List<MoviesModel> allMovies = [];
  List<MoviesModel> randomCarouselMovies = [];

    Future<void> fetchMovies() async {
      for (int i = 1; i <= 10; i++) {
        final url = Uri.parse('https://api.themoviedb.org/3/discover/tv?page=$i');
        final response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIxZTNiNzZjNjM1NDlhMTkwOGIyMjBkODM2MDQwZjYwZiIsIm5iZiI6MTc2NTYzMDI0OS40NDUsInN1YiI6IjY5M2Q2MTI5ZGM1Y2NhYjI3Yjc4MGEzMSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.lPhpkBxuecJPVWQtV3z8ayBa2An6nzn0kk_ffwoW3wc',
            'Content-Type': 'application/json;charset=utf-8',
          },
        );

        if (response.statusCode == 200) {

          final Map<String, dynamic> data = jsonDecode(response.body);
          final List results = data['results'];
          final tvShowsFromPage = results.map((json) => MoviesModel.fromJson(json)).toList();
          allMovies.addAll(tvShowsFromPage);
          print('Page $i loaded: ${tvShowsFromPage.length} items');
        } else {
          throw Exception('Failed on page $i: ${response.statusCode}');
        }
      }
      print('Total TV Shows Loaded: ${allMovies.length}');
    }

  @override
  Widget build(BuildContext context) {
    final controller = FlowDrawerController();

    final List<Widget> items = [
      FlowDrawerMenuItem(
        icon: Icon(Icons.home, size: 22, color: Colors.white),
        text: "Home",
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => NetflixStyleHome())),
        controller: controller,
      ),
      FlowDrawerMenuItem(
        icon: Icon(Icons.live_tv_sharp, size: 22, color: Colors.white),
        text: "My List",
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => WatchList())),
        controller: controller,
      ),
      FlowDrawerMenuItem(
        icon: Icon(Icons.person, size: 22, color: Colors.white),
        text: "Profile",
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ProfileScreen())),
        controller: controller,
      ),
      SizedBox(height: 40),
    ];

    return FlowDrawer(
      controller: controller,
      drawerItems: items,
      enableTopMenu: true,
      color: Colors.black,
      shadowCardColor: Color(0xffc1071e),
      shadowCardColorAlpha: -10,
      topMenu: FlowTopMenu(
        menuWidth: double.infinity,
        controller: controller,
        leftMenuIcon: Icon(Icons.arrow_back_ios, size: 0),
        onRightTap: () => controller.close(),
        rightMenuIcon: Icon(Icons.close_outlined, size: 22, color: Colors.white),
        leftMenuBgColor: Colors.black,
      ),
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: SpinKitCubeGrid(
                  color: Color(0xffd90c1a),
                ),
              ),
            );

          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Image(image: AssetImage("assets/images/netflixLogo1.png")),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: NetflixSearchDelegate(allMovies: allMovies),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    controller.toggle();
                  },
                ),
              ],
            ),
            body: AnimatedBuilder(
              animation: _glassyAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _getGlassyGradientColors(),
                      stops: [
                        0.0 + _glassyAnimation.value * 0.15,
                        0.5,
                        1.0 - _glassyAnimation.value * 0.15,
                      ],
                    ),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          _getBackgroundColor().withOpacity(0.3),
                          _getBackgroundColor(),
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Container(
                              height: 62.h,
                              child: FanCarouselImageSlider.sliderType1(
                                imagesLink: randomCarouselMovies.map((movie) {
                                  return "https://image.tmdb.org/t/p/w500${movie.posterPath}";
                                }).toList(),
                                imageFitMode: BoxFit.cover,
                                isAssets: false,
                                autoPlay: false,
                                sliderHeight: 60.h,
                                sliderWidth: 100.w,
                                expandFitAndZoomable: false,
                                isClickable: false,
                                autoPlayInterval: Duration(seconds:5),
                                currentItemShadow: [
                                  BoxShadow(
                                    color: Color(0xffe50913).withOpacity(0.5),
                                    blurRadius: 5,
                                    spreadRadius: 5,
                                  )
                                ],
                                slideViewportFraction: 0.85,
                                showIndicator: false,
                                indicatorActiveColor: Color(0xffd90c1a),
                                indicatorDeactiveColor: Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildListDelegate([
                              _buildContentRow('Trending Now', allMovies.take(15).toList()),
                              _buildContentRow('Popular on Netflix', allMovies.reversed.toList()),
                              _buildContentRow('Continue Watching', allMovies.take(10).toList()),
                              _buildContentRow('My List', allMovies.skip(10).take(10).toList()),
                              _buildContentRow('New Releases', allMovies.skip(30).take(15).toList()),
                              _buildContentRow('Action Movies', allMovies.skip(20).take(15).toList()),
                              const SizedBox(height: 50),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      ),
    );
  }

  Widget _buildContentRow(String title, List<MoviesModel> movies) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Spacer(),
            title == "Popular on Netflix" || title == "My List"
                ? InkWell(
                onTap: () {
                 title == "Popular on Netflix"? navigateWithTransitionPush(context, AllMovies(movies: allMovies)):
                 navigateWithTransitionPush(context, WatchList());
                },
                child: buildTexts("See All ", Colors.white, 16.sp, FontWeight.bold))
                : Container(),
            SizedBox(width: 1.w),
          ],
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: InkWell(
                  onTap: () {
                    navigateWithTransitionPush(
                        context,
                        MoviesDescriptions(
                          realseYear: movies[index].firstAirDate,
                          name: movies[index].name,
                          desciprtion: movies[index].overview,
                          rating: movies[index].voteAverage,
                          poster: movies[index].posterPath,
                          language: movies[index].originalLanguage,
                          isAdult: movies[index].adult,
                        ));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w342${movie.posterPath}',
                        width: 130,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}