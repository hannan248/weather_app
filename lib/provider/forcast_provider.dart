import 'package:flutter/material.dart';
import 'package:weather_app/config/config.dart';
import 'package:weather_app/model/forcast_weather.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ForcastProvider extends ChangeNotifier {
  List<Hour>? hourlyWeather;

  Future<void> fetchHourlyWeather(double lat, double lon) async {
    const apiKey = Config.apiKey;
    final url = 'https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$lat,$lon';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final forecast = Forecast.fromJson(data['forecast']);
      hourlyWeather = forecast.forecastday?.first.hour;
      notifyListeners();
    } else {
      throw Exception('Failed to load hourly weather');
    }
  }
}
