import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/provider/day_provider.dart';

class DayScreen extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const DayScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
   double screenWidth=MediaQuery.of(context).size.width;
   double screenHeight=MediaQuery.of(context).size.height;
    final dayProvider = Provider.of<DayProvider>(context);
    if (dayProvider.forecast.isEmpty) {
      dayProvider.fetchWeatherForecast(latitude, longitude);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(locationName,style: GoogleFonts.acme(fontSize: 30)),
      ),
      body: dayProvider.forecast.isNotEmpty
          ? ListView.builder(
        itemCount: dayProvider.forecast.length,
        itemBuilder: (context, index) {

          final forecastItem = dayProvider.forecast[index];
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(

              width: screenWidth*0.80,
              height: screenHeight*0.15,
              decoration:  BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: ListTile(
                leading: Text("${forecastItem.day.avgtempC.toStringAsFixed(0)}°C",style: GoogleFonts.acme(fontSize: 30),),
                title: Column(
                  children: [
                    Text(
                      DateFormat('EEEE').format(DateTime.parse(forecastItem.date)),
                      style: GoogleFonts.acme(fontSize: 30),
                    ),
                    SizedBox(height: screenHeight*0.01,),
                    Text(
                      DateFormat(' d, MMM ').format(DateTime.parse(forecastItem.date)),
                      style: GoogleFonts.acme(fontSize: 25),
                    ),
                  ],
                ),

                trailing: Image.network(
                  "http:${forecastItem.day.condition.icon}",
                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                    // Display an error icon if the image fails to load
                    return const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 40,
                    );
                  },
                ),
                // Other properties...
              ),
            ),
          );
        },
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
