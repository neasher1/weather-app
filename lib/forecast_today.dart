import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/seven_day_forecast.dart';

class ForecastTodayPage extends StatefulWidget {
  const ForecastTodayPage({super.key});

  @override
  State<ForecastTodayPage> createState() => _ForecastTodayPageState();
}

class _ForecastTodayPageState extends State<ForecastTodayPage> {
  Map<String, dynamic>? forecastData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchForecastData();
  }

  Future<void> fetchForecastData() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final apiKey = 'a48fe24ccfac45bab57152344241411';
    final forecastUrl =
        'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=${position.latitude},${position.longitude}&days=1&hourly=1';

    try {
      final response = await http.get(Uri.parse(forecastUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          forecastData = data;
          isLoading = false;
        });
      } else {
        print('Failed to load forecast data');
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
        title: const Text("Forecast for Today"),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            // Swipe detected, navigate to the 7-day forecast page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SevenDayForecastPage(),
              ),
            );
          }
        },
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Forecast for ${forecastData!['location']['name']}',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Condition: ${forecastData!['current']['condition']['text']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Text(
                      'Temperature: ${forecastData!['current']['temp_c']}°C',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hourly forecast:',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Hourly forecast ListView
                    Expanded(
                      child: ListView.builder(
                        itemCount: forecastData!['forecast']['forecastday'][0]
                                ['hour']
                            .length,
                        itemBuilder: (context, index) {
                          var hourData = forecastData!['forecast']
                              ['forecastday'][0]['hour'][index];
                          String time = hourData['time']
                              .substring(11, 16); // Extract time (HH:mm)
                          double tempC = hourData['temp_c'];
                          String condition = hourData['condition']['text'];

                          return ListTile(
                            title: Text(
                              '$time - $tempC°C',
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              condition,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
