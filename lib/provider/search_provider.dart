import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/config/config.dart';
import 'package:weather_app/model/search.dart';

class SearchProvider with ChangeNotifier {
  List<Search> _searchResults = [];
  List<Search> get searchResults => _searchResults;
  bool _isSearching = false; // Variable to track search state
  bool get isSearching => _isSearching; // Getter for isSearching

  Future<void> searchLocation(String query) async {
    _isSearching = true; // Set isSearching to true when search starts
    notifyListeners();

    const String apiKey = Config.apiKey;
    final url = 'http://api.weatherapi.com/v1/search.json?key=$apiKey&q=$query';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _searchResults = data.map((json) => Search.fromJson(json)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      print("Error fetching search results: $e");
    } finally {
      _isSearching = false; // Set isSearching back to false when search completes
      notifyListeners();
    }
  }
}
