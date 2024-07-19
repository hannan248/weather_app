import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/config/config.dart';
import 'dart:convert';

import 'package:weather_app/model/forcast_weather.dart';

class DayProvider extends ChangeNotifier {
  List<Forecastday> _forecast = [];

  List<Forecastday> get forecast => _forecast;

  Future<void> fetchWeatherForecast(double latitude, double longitude) async {
    const apiKey = Config.apiKey;
    final url =
        'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$latitude,$longitude&days=14';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      _forecast = Forecast.fromJson(jsonData['forecast']).forecastday;
      notifyListeners();
    } else {
      throw Exception('Failed to load forecast');
    }
  }
}
