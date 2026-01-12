import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../DataModels/MoviesDataModel.dart';

class TEST  extends StatelessWidget {
  const TEST ({super.key});

  @override
  Widget build(BuildContext context) {

   List <MoviesModel> allMovies = [];

    Future<void> fetchMovies() async {
      for (int i =1 ; i<=10;i++) {
        final url = Uri.parse(
            'https://api.themoviedb.org/3/discover/tv?page=$i');
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

          final tvShowsFromPage = results
              .map((json) => MoviesModel.fromJson(json))
              .toList();

          allMovies.addAll(tvShowsFromPage);

          print('Page $i loaded: ${tvShowsFromPage.length} items');
        } else {
          throw Exception('Failed on page $i: ${response.statusCode}');
        }
      }

      print('Total TV Shows Loaded: ${allMovies.length}');



    }


    print(allMovies.first);



    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InkWell(
            onTap: (){
              fetchMovies();
            },
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.red,
              ),
            ),

          )
        ],
      ),

    );
  }
}
