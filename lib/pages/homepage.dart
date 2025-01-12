import 'package:final_project_template/pages/detailpage.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/weather_service.dart';
import '../models/weather_response.dart';
import '../main.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _weatherService = WeatherService();
  String city = 'Loading...';
  double temperature = 0.0;
  String mainCondition = 'Loading...';
  List<DailyWeather> dailyForecast = []; // Store forecast data.

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  // Calling the API to get the weather.
  Future<void> _getWeather() async {
    try {
      String currentCity = await _weatherService.getCurrentCity();
      WeatherResponse weather =
          await _weatherService.getWeatherForCurrentLocation();

      setState(() {
        city = currentCity;
        temperature = weather.current.temp;
        mainCondition = weather.current.weather.first.main;
        dailyForecast = weather.daily.take(6).toList(); // Get next 5 days.
      });
    } catch (e) {
      setState(() {
        city = "Error: ${e.toString()}";
        temperature = 0.0;
        mainCondition = "Error Fetching Condition";
        dailyForecast = [];
      });
    }
  }

  // Function to help formate the day beside the date with the help of Google and AI.
  String formatDateWithDay(int timestamp) {
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();
    String weekday = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ][date.weekday % 7];
    return "$weekday, ${date.toString().split(' ')[0]}";
  }

  // Selecting the proper animation.
  String _getWeatherAnimation(String? mainCondition) {
    if (mainCondition == null) return 'assets/unknown.json';
    switch (mainCondition.toLowerCase()) {
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
        return 'assets/cloudy.json';
      case 'fog':
        return 'assets/fog.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunderstorm.json';
      case 'snow':
      case 'sleet':
      case 'hail':
        return 'assets/snowing.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/unknown.json';
    }
  }

  // Getting the date and building the nav path to the detail page.
  void navigateToDetails(BuildContext context, DailyWeather weather) {
    String date = DateTime.fromMillisecondsSinceEpoch(weather.dt * 1000)
        .toLocal()
        .toString()
        .split(' ')[0]; // Convert timestamp to date.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeatherDetailPage(
          date: date,
          weather: weather,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          // Current weather details wrapped in GestureDetector.
          GestureDetector(
            onTap: () {
              if (dailyForecast.isNotEmpty) {
                navigateToDetails(context, dailyForecast.first);
              }
            },
            child: Column(
              children: [
                Text(
                  '$city',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                // Lottie animation provided.
                Lottie.asset(_getWeatherAnimation(mainCondition), height: 200),
                Text(
                  '$temperature°C',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '$mainCondition',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          // Scrollable ListView for forecast.
          Expanded(
            child: dailyForecast.isNotEmpty
                ? ListView.builder(
                    // Adjust the item count as needed
                    itemCount: dailyForecast.length - 1,
                    itemBuilder: (context, index) {
                      // Adding one to skip the first entry.
                      final day = dailyForecast[index + 1];
                      // GestureDetector to allow for selection.
                      // Also alot of formatting.
                      return GestureDetector(
                        onTap: () => navigateToDetails(context, day),
                        child: Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                          elevation: 8,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Lottie.asset(
                                    _getWeatherAnimation(
                                        day.weather.first.main),
                                    height: 100,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formatDateWithDay(day.dt),
                                      ),
                                      Text(
                                        day.weather.first.main,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge,
                                      ),
                                      Text(
                                        "Day Temp: ${day.temp.day.toStringAsFixed(1)}°C\nMax: ${day.temp.max.toStringAsFixed(1)}°C, Min: ${day.temp.min.toStringAsFixed(1)}°C",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                // if the result is zero, or permissions are not accepted yet.
                : Center(
                    child: Text(
                      'No forecast data available.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
