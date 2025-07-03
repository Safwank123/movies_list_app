import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app/models/movie_model.dart';

class MovieProvider with ChangeNotifier {
  static const String _apiKey = 'a5ff1e81f237d4b025cfa438b428cf62';
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  List<Movie> _movies = [];
  List<Movie> _searchResults = [];
  bool _isLoading = false;
  String _error = '';

  List<Movie> get movies => _movies;
  List<Movie> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get error => _error;

 
  Future<void> fetchPopularMovies() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _movies = (data['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
      } else {
        _error = 'Failed to load movies';
      }
    } catch (e) {
      _error = 'Network error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  
  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=${Uri.encodeComponent(query)}'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _searchResults = (data['results'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
      } else {
        _error = 'Failed to search movies';
      }
    } catch (e) {
      _error = 'Network error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  String getFullImageUrl(String posterPath) {
    return posterPath.isNotEmpty ? '$_imageBaseUrl$posterPath' : '';
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}