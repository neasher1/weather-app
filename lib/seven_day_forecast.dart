import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

class SevenDayForecastPage extends StatefulWidget {
  const SevenDayForecastPage({super.key});

  @override
  State<SevenDayForecastPage> createState() => _SevenDayForecastPageState();
}

class _SevenDayForecastPageState extends State<SevenDayForecastPage> {
  Map<String, dynamic>? forecastData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSevenDayForecast();
  }

  Future<void> fetchSevenDayForecast() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final apiKey = 'a48fe24ccfac45bab57152344241411';
    final forecastUrl =
        'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=${position.latitude},${position.longitude}&days=7';

    try {
      final response = await http.get(Uri.parse(forecastUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          forecastData = data;
          isLoading = false;
        });
      } else {
        print('Failed to load 7-day forecast data');
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
        title: const Text('7-Day Forecast'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: forecastData!['forecast']['forecastday'].length,
                itemBuilder: (context, index) {
                  var dayData = forecastData!['forecast']['forecastday'][index];
                  var date = dayData['date'];
                  var tempMin = dayData['day']['mintemp_c'];
                  var tempMax = dayData['day']['maxtemp_c'];
                  var condition = dayData['day']['condition']['text'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(date),
                      subtitle:
                          Text('$condition - Min: $tempMin°C, Max: $tempMax°C'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
