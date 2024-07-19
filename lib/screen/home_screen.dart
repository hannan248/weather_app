import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/provider/forcast_provider.dart';
import 'package:weather_app/provider/search_provider.dart';
import 'package:weather_app/provider/theme_provider.dart';
import 'package:weather_app/provider/weather_provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/screen/14_day.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndFetchData();
  }

  Future<void> _getCurrentLocationAndFetchData() async {
    setState(() {
      isLoading = true; // Set loading state to true when fetching data
    });
    try {
      final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      await Provider.of<WeatherProvider>(context, listen: false)
          .fetchWeather(position.latitude, position.longitude);
      await Provider.of<ForcastProvider>(context, listen: false)
          .fetchHourlyWeather(position.latitude, position.longitude);
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: Text("Error getting location or fetching data: $e"),
            actions: <Widget>[
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        isLoading = false; // Set loading state to false after fetching data
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final forecastProvider = Provider.of<ForcastProvider>(context);
    final searchProvider = Provider.of<SearchProvider>(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: isLoading // Check the loading state here
          ? _buildShimmerEffect(screenWidth,
              screenHeight) // Use shimmer effect instead of circular progress indicator
          : weatherProvider.weather != null &&
                  forecastProvider.hourlyWeather != null
              ? SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        searchBox(),
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        SizedBox(
                          width: screenWidth * 0.90,
                          child: Card(
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    weatherProvider.weather!.location!.name ??
                                        '',
                                    style: GoogleFonts.bebasNeue(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 30,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('EEEE dd MMMM')
                                        .format(DateTime.now()),
                                    style: GoogleFonts.bebasNeue(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 30,
                                    ),
                                  ),
                                  Text(
                                    "${weatherProvider.weather!.current!.tempC!.toStringAsFixed(0)}°",
                                    style: GoogleFonts.bebasNeue(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 190,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            cardWidget(
                                screenHeight,
                                screenWidth,
                                "wind",
                                "Wind",
                                "${weatherProvider.weather!.current!.windKph.toString()} km/h"),
                            cardWidget(
                                screenHeight,
                                screenWidth,
                                "humidity",
                                "Humidity",
                                "${weatherProvider.weather!.current!.humidity.toString()} %"),
                            cardWidget(
                                screenHeight,
                                screenWidth,
                                "thermometer",
                                "Feels Like",
                                "${weatherProvider.weather!.current!.feelslikeC.toString()}° "),
                          ],
                        ),
                        Container(
                          height: 160,
                          child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: forecastProvider.hourlyWeather!.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(right: 10.0, top: 8),
                                child: timeWeather(
                                  DateFormat('hh:mm a').format(DateTime.parse(
                                      forecastProvider
                                          .hourlyWeather![index].time)),
                                 forecastProvider.hourlyWeather![index].condition.icon,
                                  forecastProvider.hourlyWeather![index].tempC!
                                      .toStringAsFixed(0),
                                ),
                              );
                            },
                          ),
                        ),


                      ],
                    ),
                  ),
                )
              : errorMessage != null
                  ? Center(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _buildShimmerEffect(screenWidth, screenHeight),
    );
  }

  Widget cardWidget(
      double height, double width, String pic, String name, String data) {
    return SizedBox(
      height: height * 0.20,
      width: width * 0.30,
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image(
              image: AssetImage("assets/$pic.png"),
              height: 40,
              width: 40,
            ),
            Text(name),
            Text(data)
          ],
        ),
      ),
    );
  }

  Widget timeWeather(String time, String icon, String degree) {
    return SizedBox(
      height: 150,
      width: 150,
      child: Card(
        elevation: 10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              time,
              style: GoogleFonts.bebasNeue(
                fontWeight: FontWeight.w500,
                fontSize: 25,
              ),
            ),
            // Image with error handling
            Image.network(
              "http:$icon",
              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                // Display an error icon if the image fails to load
                return const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 40,
                );
              },
            ),
            Text(
              "$degree°",
              style: GoogleFonts.bebasNeue(
                fontWeight: FontWeight.w500,
                fontSize: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget searchBox() {
    return Consumer<SearchProvider>(
      builder: (context, searchProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            hintText: "Search",
                            prefixIcon: const Icon(Icons.search),
                          ),
                          onChanged: (query) {
                            if (query.isNotEmpty) {
                              searchProvider.searchLocation(query);
                            }
                          },
                        ),
                        if (searchProvider
                            .isSearching) // Show circular progress indicator if searching
                          const Positioned(
                            right: 10,
                            top: 10,
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      await _getCurrentLocationAndFetchData();
                    },
                    icon: const Icon(Icons.refresh),
                  ),
                  IconButton(
                    onPressed: () {
                      _showOptionsDialog(context);
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              if (searchProvider.searchResults.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount: searchProvider.searchResults.length,
                    itemBuilder: (context, index) {
                      final searchResult = searchProvider.searchResults[index];
                      return ListTile(
                        title: Text(searchResult.name!),
                        subtitle: Text(
                            '${searchResult.region}, ${searchResult.country}'),
                        onTap: () async {
                          // Handle the location selection asynchronously
                          // Show circular progress indicator when fetching data
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            // Prevent user from dismissing dialog
                            builder: (BuildContext context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );

                          // Fetch weather data for the selected location
                          await Provider.of<WeatherProvider>(context,
                                  listen: false)
                              .fetchWeather(
                                  searchResult.lat!, searchResult.lon!);
                          await Provider.of<ForcastProvider>(context,
                                  listen: false)
                              .fetchHourlyWeather(
                                  searchResult.lat!, searchResult.lon!);

                          // Dismiss the circular progress indicator dialog
                          Navigator.pop(context);

                          // Clear search results and text field
                          _searchController.clear();
                          searchProvider.searchResults.clear();
                          // Hide the keyboard
                          _searchFocusNode.unfocus();
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerEffect(screenWidth, screenHeight) {
    return Center(
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Container(
                color: Colors.black,
                child: const TextField(),
              ),
            ),
            SizedBox(
              height: screenHeight * 0.02,
            ),
            Container(
              width: screenWidth * 0.90,
              height: screenHeight * 0.50,
              color: Colors.black,
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  Container(
                    color: Colors.black,
                    height: screenHeight * 0.20,
                    width: screenWidth * 0.25,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    color: Colors.black,
                    height: screenHeight * 0.20,
                    width: screenWidth * 0.25,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    color: Colors.black,
                    height: screenHeight * 0.20,
                    width: screenWidth * 0.25,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    // Get the current weather data to pass to the DayScreen
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final locationName = weatherProvider.weather?.location?.name ?? '';
    final latitude = weatherProvider.weather?.location?.lat ?? 0.0;
    final longitude = weatherProvider.weather?.location?.lon ?? 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("Change Theme"),
                onTap: () {
                  Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("View 14-day Forecast"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>DayScreen(
                        latitude: latitude,
                        longitude: longitude,
                        locationName: locationName,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
