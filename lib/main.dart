import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/forecast_today.dart';
import 'package:weather_app/search_city_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchWeatherData();
  }

  Future<void> fetchWeatherData() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final apiKey = 'a48fe24ccfac45bab57152344241411';
    final weatherUrl =
        'http://api.weatherapi.com/v1/current.json?key=$apiKey&q=${position.latitude},${position.longitude}';

    try {
      final response = await http.get(Uri.parse(weatherUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          weatherData = data;
          isLoading = false;
        });
      } else {
        print('Failed to load weather data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    return permission != LocationPermission.deniedForever;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to SearchCityPage when search icon is clicked
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchCityPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ForecastTodayPage(),
              ),
            );
          }
        },
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      '/weather_background.jpg'), // Ensure this path is correct
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          color: getBackgroundColor(
                              weatherData!['current']['temp_c']),
                          margin: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(26.0),
                            child: Column(
                              children: [
                                Text(
                                  '${weatherData!['location']['name']}',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  '${weatherData!['current']['temp_c']}°C',
                                  style: const TextStyle(
                                      fontSize: 50,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  '${weatherData!['current']['condition']['text']}',
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Humidity: ${weatherData!['current']['humidity']}%",
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                    Text(
                                      "Wind: ${weatherData!['current']['wind_kph']} km/h",
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Feels Like: ${weatherData!['current']['feelslike_c']}°C",
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color getBackgroundColor(double temperature) {
    if (temperature < 10) {
      return Colors.lightBlueAccent;
    } else if (temperature < 25) {
      return Colors.lightGreen;
    } else if (temperature < 35) {
      return Colors.orangeAccent;
    } else {
      return Colors.redAccent;
    }
  }
}
