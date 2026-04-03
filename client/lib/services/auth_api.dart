import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/attendance.dart';
import 'package:halqati/models/event.dart';
import 'package:halqati/models/teacher.dart';
import 'package:http/http.dart' as http;
import 'package:halqati/models/student.dart';
import 'package:halqati/models/class_model.dart';
import 'package:halqati/test/printJson.dart';
import 'package:halqati/services/base_api.dart';

class AuthApi extends BaseApi{

  Future <Map<String, dynamic>?> login(String phone, String pin) async {

    final url = Uri.parse('$baseUrl/auth/login/user');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'password': pin,
        }),
      );

      print("statusCode: ${response.statusCode}");
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return responseBody;

      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        final message = responseBody['message'] ?? 'Authentication failed.';
        print('Login Failed: $message');
        return null;

      } else {
        print('Server Error: ${response.statusCode}');
        return null;
      }

    } catch (e) {
      print('Network connection failed or data invalid: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile(String token) async {
    final url = Uri.parse('$baseUrl/auth/auth_me/user');
    try {
      print("profile method has been called");
      print("token: $token");

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      print("status code: ${response.statusCode}");

      // response.statusCode == 404
      if (response.statusCode == 401 || response.statusCode == 404) {
        print("Unauthorized - invalid token");
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        printJson(responseBody, "auth me method");
        return responseBody;
      } else {
        // For other errors, try to decode or return raw body
        print("API error: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw ApiException(
          'Failed to fetch profile: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }

    } on SocketException {
      print("Network error - no internet connection");
      throw NetworkException();
    } on TimeoutException {
      print("Network timeout");
      throw NetworkException();
    } on UnauthorizedException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on FormatException catch (e) {
      // ✅ Handle JSON parsing errors explicitly
      print("Failed to parse JSON response: $e");
      throw ApiException('Invalid response format from server');
    } catch (e) {
      print("Unexpected error in getProfile: $e");
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<Student> getStudentDashboard (String token) async {
    final url = Uri.parse('$baseUrl/auth/auth_me/user');
    try{
      final response = await http.get(
          url,
          headers: {
            'Authorization':'Bearer $token',
            'Access':'application/json'
          }
      ).timeout(Duration(seconds: 10));
      print("response.statusCode: ${response.statusCode}");
      if (response.statusCode == 401){
        throw UnauthorizedException();
      }

      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        return Student.fromJson(data["user"]);
      }
      return Student.emptyStudent();

    } on SocketException{
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    } on UnauthorizedException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      // if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

}