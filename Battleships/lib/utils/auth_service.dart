import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://165.227.117.48';

  Future<Map<String, dynamic>> registerUser(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData.containsKey('access_token')) {
        return responseData;
      } else {
        throw Exception(
            'Registration succeeded but no access token was provided.');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['error'] ?? 'An unknown error occurred.');
    }
  }

  // Simplified validation in loginUser as well
  Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Invalid username or password');
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }
}
