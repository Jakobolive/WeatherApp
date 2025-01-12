import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/weather_service.dart';
import '../models/weather_response.dart';

import '../main.dart';

class WeatherDetailPage extends StatelessWidget {
  final String date;
  final DailyWeather weather;

  const WeatherDetailPage({
    Key? key,
    required this.date,
    required this.weather,
  }) : super(key: key);
  // Getting the day matching the date provided.
  String getDayName(int timestamp) {
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

  // Getting the proper weather animation.
  String getWeatherAnimation(String? mainCondition) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Weather Details"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display day and date.
              Text(
                "${getDayName(weather.dt)}",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              // Weather animation.
              Lottie.asset(
                getWeatherAnimation(weather.weather.first.main),
                height: 100,
              ),
              const SizedBox(height: 5),
              // Main weather condition.
              Text(
                weather.weather.first.main,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              // Weather summary.
              Text(
                "Summary: ${weather.summary}",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              // Temperature details.
              Text(
                "Day Temp: ${weather.temp.day.toStringAsFixed(1)}°C",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              Text(
                "Max Temp: ${weather.temp.max.toStringAsFixed(1)}°C",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              Text(
                "Min Temp: ${weather.temp.min.toStringAsFixed(1)}°C",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              // Wind details.
              Text(
                "Wind Speed: ${weather.windSpeed} m/s",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              Text(
                "Wind Gust: ${weather.windGust ?? 'N/A'} m/s",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              // Humidity, Pressure, Dew Point.
              Text(
                "Humidity: ${weather.humidity}%",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              Text(
                "Pressure: ${weather.pressure} hPa",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              Text(
                "Dew Point: ${weather.dewPoint}°C",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              // UV Index and Clouds.
              Text(
                "UV Index: ${weather.uvi}",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              Text(
                "Clouds: ${weather.clouds}%",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              // Rain and Snow (if available).
              if (weather.rain != null)
                Text(
                  "Rain: ${weather.rain} mm",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              if (weather.snow != null)
                Text(
                  "Snow: ${weather.snow} mm",
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 1),
              // Moonrise, Moonset.
              Text(
                "Moonrise: ${DateTime.fromMillisecondsSinceEpoch(weather.moonrise * 1000).toLocal()}",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 1),
              Text(
                "Moonset: ${DateTime.fromMillisecondsSinceEpoch(weather.moonset * 1000).toLocal()}",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
