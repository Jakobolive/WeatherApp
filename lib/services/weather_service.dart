import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import '../models/weather_response.dart';
import '../config/secrets.dart';

class WeatherService {
  // Defining the base URL as well as the API key for the OpenWeatherMap API, as it seemed
  // more efficient to do it here rather than in the page.
  static const String BASE_URL =
      'https://api.openweathermap.org/data/3.0/onecall';
  static const String API_KEY = Secrets.apiKey;

  /// Fetch weather data using latitude and longitude.
  Future<WeatherResponse> getWeather(double lat, double lon) async {
    try {
      final uri = Uri.parse(
          '$BASE_URL?lat=$lat&lon=$lon&exclude=hourly,minutely&units=metric&appid=$API_KEY');
      final response = await http.get(uri);

      // Checking the response.
      if (response.statusCode == 200) {
        return WeatherResponse.fromJson(jsonDecode(response.body));
      } else {
        print('Error fetching weather data: ${response.body}');
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error in getWeather: $e');
      throw Exception('Error while fetching weather: $e');
    }
  }

  /// Fetch the user's current location and use it to fetch weather data.
  Future<WeatherResponse> getWeatherForCurrentLocation() async {
    try {
      Position position = await _getCurrentPosition();
      return getWeather(position.latitude, position.longitude);
    } catch (e) {
      print('Error in getWeatherForCurrentLocation: $e');
      rethrow;
    }
  }

  /// Detect city name from latitude and longitude from another API.
  Future<String> getCityFromCoordinates(double lat, double lon) async {
    try {
      final uri = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['address']['city'] ?? "Unknown City";
      } else {
        return "Error fetching city";
      }
    } catch (e) {
      print('Error in getCityFromCoordinates: $e');
      return "Error fetching city";
    }
  }

  /// Fetch the current location and detect the city name.
  Future<String> getCurrentCity() async {
    try {
      // Get the current position
      Position position = await _getCurrentPosition();
      // Log position for debugging
      print(
          'Current position: lat=${position.latitude}, lon=${position.longitude}');

      // Fetch the city from the coordinates
      return await getCityFromCoordinates(
          position.latitude, position.longitude);
    } catch (e) {
      print('Error in getCurrentCity: $e');
      return "Error fetching city: $e";
    }
  }

  /// Helper method to get the user's current position.
  Future<Position> _getCurrentPosition() async {
    try {
      // Ensure location permissions are granted.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      // Get the user's current position.
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      print('Error in _getCurrentPosition: $e');
      throw Exception('Error fetching current location: $e');
    }
  }
}
