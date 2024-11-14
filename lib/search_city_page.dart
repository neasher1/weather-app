import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchCityPage extends StatefulWidget {
  const SearchCityPage({super.key});

  @override
  State<SearchCityPage> createState() => _SearchCityPageState();
}

class _SearchCityPageState extends State<SearchCityPage> {
  TextEditingController searchController = TextEditingController();
  Map<String, dynamic>? weatherData;
  bool isLoading = false;

  Future<void> fetchWeatherData(String city) async {
    setState(() {
      isLoading = true;
    });

    final apiKey = 'a48fe24ccfac45bab57152344241411'; // Your API Key
    final weatherUrl =
        'https://api.weatherapi.com/v1/current.json?key=$apiKey&q=$city';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search City'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (searchController.text.isNotEmpty) {
                      fetchWeatherData(searchController.text);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : weatherData != null
                    ? Column(
                        children: [
                          Text(
                            'Weather in ${weatherData!['location']['name']}',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${weatherData!['current']['temp_c']}°C',
                            style: const TextStyle(fontSize: 50),
                          ),
                          Text(
                            '${weatherData!['current']['condition']['text']}',
                            style: const TextStyle(fontSize: 20),
                          ),
                          Text(
                            'Humidity: ${weatherData!['current']['humidity']}%',
                          ),
                          Text(
                            'Wind: ${weatherData!['current']['wind_kph']} km/h',
                          ),
                          Text(
                            'Feels Like: ${weatherData!['current']['feelslike_c']}°C',
                          ),
                        ],
                      )
                    : const Text('No data available'),
          ],
        ),
      ),
    );
  }
}
