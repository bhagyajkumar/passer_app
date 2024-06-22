import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String baseUrl = "https://0a72a0ea-9977-4705-ae86-3f7222612213-00-2kmfclt20hfeu.janeway.replit.dev/api";

  // Retrieve authentication headers including the access token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Method to perform a request with automatic token refresh and retry
  Future<http.Response> _performRequest(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    Map<String, String> headers = await _getHeaders();
    http.Response response = await request(headers);

    if (response.statusCode == 401) {
      // Token might be expired, try to refresh the token
      await refreshToken();
      // Retry the request with new headers
      headers = await _getHeaders();
      response = await request(headers);
    }

    return response;
  }

  // Event Services
  Future<List<dynamic>> getEvents() async {
    final response = await _performRequest(
      (headers) => http.get(Uri.parse('$baseUrl/events/'), headers: headers),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<Map<String, dynamic>> getEvent(String id) async {
    final response = await _performRequest(
      (headers) => http.get(Uri.parse('$baseUrl/events/$id/'), headers: headers),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load event');
    }
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> eventData) async {
    final response = await _performRequest(
      (headers) => http.post(
        Uri.parse('$baseUrl/events/'),
        headers: headers,
        body: json.encode(eventData),
      ),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create event');
    }
  }

  Future<void> updateEvent(String id, Map<String, dynamic> eventData) async {
    final response = await _performRequest(
      (headers) => http.put(
        Uri.parse('$baseUrl/events/$id/'),
        headers: headers,
        body: json.encode(eventData),
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update event');
    }
  }

  Future<void> deleteEvent(String id) async {
    final response = await _performRequest(
      (headers) => http.delete(Uri.parse('$baseUrl/events/$id/'), headers: headers),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete event');
    }
  }

  // Ticket Services
  Future<List<dynamic>> getTickets() async {
    final response = await _performRequest(
      (headers) => http.get(Uri.parse('$baseUrl/tickets/'), headers: headers),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load tickets');
    }
  }

  Future<Map<String, dynamic>> getTicket(String id) async {
    final response = await _performRequest(
      (headers) => http.get(Uri.parse('$baseUrl/tickets/$id/'), headers: headers),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load ticket');
    }
  }

  Future<Map<String, dynamic>> createTicket(Map<String, dynamic> ticketData) async {
    final response = await _performRequest(
      (headers) => http.post(
        Uri.parse('$baseUrl/tickets/'),
        headers: headers,
        body: json.encode(ticketData),
      ),
    );
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create ticket');
    }
  }

  Future<void> updateTicket(String id, Map<String, dynamic> ticketData) async {
    final response = await _performRequest(
      (headers) => http.put(
        Uri.parse('$baseUrl/tickets/$id/'),
        headers: headers,
        body: json.encode(ticketData),
      ),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update ticket');
    }
  }

  Future<void> deleteTicket(String id) async {
    final response = await _performRequest(
      (headers) => http.delete(Uri.parse('$baseUrl/tickets/$id/'), headers: headers),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete ticket');
    }
  }

  // Authentication Services
  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access']);
      await prefs.setString('refresh_token', data['refresh']);
    } else {
      throw Exception('Failed to login');
    }
  }

  

  Future<void> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh': refreshToken}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await prefs.setString('access_token', data['access']);
    } else {
      // Optionally handle token refresh failure (e.g., force logout)
      throw Exception('Failed to refresh token');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // User Registration
  Future<void> registerUser(String username, String password, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password, 'email': email}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to register user');
    }
  }
}
