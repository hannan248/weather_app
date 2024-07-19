import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/provider/LocationProvider.dart';
import 'package:weather_app/provider/day_provider.dart';
import 'package:weather_app/provider/search_provider.dart';
import 'package:weather_app/provider/theme_provider.dart';
import 'package:weather_app/provider/weather_provider.dart';
import 'package:weather_app/screen/splash_screen.dart';

import 'provider/forcast_provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => ForcastProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DayProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: themeProvider.themeData,
      home: const SplashScreen(),
    );
  }
}

