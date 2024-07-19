import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/config/config.dart';
import 'package:weather_app/model/weather.dart';


class WeatherProvider with ChangeNotifier {
  Weather? _weather;
  String _error = '';

  Weather? get weather => _weather;
  String get error => _error;

  Future<void> fetchWeather(double lat, double lon) async {
    const apiKey = Config.apiKey;
    final url = 'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$lat,$lon';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        _weather = Weather.fromJson(data);
        _error = '';
      } else {
        _error = 'Failed to fetch weather data';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    notifyListeners();
  }
}
