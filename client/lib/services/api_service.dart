import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/assignment_class.dart';
import 'package:http/http.dart' as http;
import 'package:halqati/models/student.dart';
import 'package:halqati/models/halaqa_class.dart';
import 'package:halqati/test/printJson.dart';

class ApiService {
  // 💡 IMPORTANT: Use the correct IP for your emulator/device
  // Android Emulator: 10.0.2.2
  // iOS Simulator: 127.0.0.1 (or localhost)
  // Physical Device (if on same network): Your PC's local IP (e.g., 192.168.1.10)
  static const String _baseUrl = 'https://unnotional-jayme-gamophyllous.ngrok-free.dev/api';

  Future <Map<String, dynamic>?> login(String phone, String pin) async {
    // print("this is the base url in the service page $_baseUrl");
    final url = Uri.parse('$_baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        // Crucial headers to tell Laravel to expect JSON data (Content-Type)
        // and return a JSON response (Accept)
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Encode the Dart Map into a JSON String for the request body
        body: jsonEncode({
          'phone': phone,
          'pin': pin,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // ✅ Successful Login
        // final token = responseBody['token'] as String?;
        // print('Login Success! Token: $token');
        // print(responseBody);
        return responseBody;

      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        // ❌ Client Error (403 Unauthorized, 422 Validation)
        // Check for specific error message structure from Laravel
        final message = responseBody['message'] ?? 'Authentication failed.';
        print('Login Failed: $message');

        // You might want to extract and display validation errors here:
        // final errors = responseBody['errors'];

        return null;

      } else {
        // ❌ Server Error (5xx)
        print('Server Error: ${response.statusCode}');
        return null;
      }

    } catch (e) {
      // ❌ Network/Connection Error
      print('Network connection failed or data invalid: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile(String token) async {
    final url = Uri.parse('$_baseUrl/auth/me');

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

      // ✅ CHECK STATUS CODE FIRST!
      if (response.statusCode == 401) {
        print("Unauthorized - invalid token");
        throw UnauthorizedException();
      }

      // ✅ Only decode JSON if status is success
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print("Response: $responseBody");
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

  Future<void> logout(String token) async {
    final url = Uri.parse('$_baseUrl/auth/logout');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      // ✅ CHECK STATUS CODE FIRST!
      if (response.statusCode == 401) {
        // await _clearLocalData();
        return;
      }

      // ✅ Only decode JSON if status is success
      if (response.statusCode == 200) {
        // await _clearLocalData();
        print("Logout successful");
      } else {
        throw ApiException('Failed to logout', statusCode: response.statusCode);
      }

    } on SocketException {
      print("Network error - no internet connection");
      throw NetworkException();
    } on NetworkException {
      rethrow;
    } catch (e) {
      print("Unexpected error in logout: $e");
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<bool> createClass({
    required String token,
    required String name,
    required String description,
    required int capacity,
    required String roomNumber,
    required List<String> scheduleDays, // List of days
    required String scheduleTime,       // Time string
  }) async {
    final url = Uri.parse(
        '$_baseUrl/classes'); // Assuming your endpoint is /api/classes

    // 1. Construct the complete request body Map
    final Map<String, dynamic> requestBody = {
      "name": name,
      "description": description,
      "capacity": capacity,
      "room_number": roomNumber,
      "schedule": {
        "days": scheduleDays,
        "time": scheduleTime,
      },
    };

    try {
      final response = await http.post(
        url,
        headers: {
          // 🚨 CRITICAL: Include the Bearer token in the Authorization header
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody), // Encode the whole Map to JSON
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        // print("Unauthorized - invalid token");
        throw UnauthorizedException();
      }

      if (response.statusCode == 201) {
        // ✅ Success: 201 Created is the standard for successful creation
        print('Class created successfully!');
        return true;
      }

      if (response.statusCode == 422) {
        throw ValidationException();
      }

      final responseBody = jsonDecode(response.body);
      throw ApiException(
        responseBody['message'] ?? 'Failed to create class',
        statusCode: response.statusCode,
      );
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
    } on ValidationException {
      rethrow;
    } catch (e) {
      // print("Unexpected error in getProfile: $e");
      // if (e is ApiException) rethrow;
      // throw ApiException('Unexpected error: $e');
      rethrow;
    }
  }

  Future<List<HalaqaClass>> getClasses(String token) async {
    final url = Uri.parse('$_baseUrl/classes');
    printString(token);
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if(response.statusCode == 401){
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data is List) {
          return data.map((json)
          {
            return HalaqaClass.fromJson(json["class"]);
          }
          ).toList();
        }
        return []; // Empty but valid response
      } else {
        throw ApiException(
          'Failed to fetch classes: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
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

  Future<HalaqaClass> getClass(String token, int id) async {
    final url = Uri.parse('$_baseUrl/classes/$id');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if(response.statusCode == 401){
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null) {
          return HalaqaClass.fromJson(data['class']);
        }
        return new HalaqaClass(
          id: 0,
          name: "",
        );
      } else {
        throw ApiException(
          'Failed to fetch class details: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
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
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<bool> updateClasses({
    required String token,
    required String name,
    required String description,
    required int capacity,
    required String roomNumber,
    required List<String> scheduleDays,
    required String scheduleTime,
    required int id
  }) async {

    final url = Uri.parse(
        '$_baseUrl/classes/$id');

    // 1. Construct the complete request body Map
    final Map<String, dynamic> requestBody = {
      "name": name,
      "description": description,
      "capacity": capacity,
      "room_number": roomNumber,
      "schedule": {
        "days": scheduleDays,
        "time": scheduleTime,
      },
    };

    try {
      final response = await http.put(
        url,
        headers: {
          // 🚨 CRITICAL: Include the Bearer token in the Authorization header
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody), // Encode the whole Map to JSON
      ).timeout(const Duration(seconds: 10));
      print("updateClasses: ${response.statusCode}");
      if (response.statusCode == 401) {
        // print("Unauthorized - invalid token");
        throw UnauthorizedException();
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        // ✅ Success: 201 Created is the standard for successful creation
        print('Class updated successfully!');
        return true;
      }

      if (response.statusCode == 422) {
        throw ValidationException();
      }

      final responseBody =
      response.body.isNotEmpty ? jsonDecode(response.body) : null;

      throw ApiException(
        responseBody['message'] ?? 'Failed to updated class',
        statusCode: response.statusCode,
      );
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
    } on ValidationException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Student>> getStudents(String token) async {
    final url = Uri.parse('$_baseUrl/teacher/students');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if(response.statusCode == 401){
        throw UnauthorizedException();
      }

      // printJson(jsonDecode(response.body), 'getStudent');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data is List) {
          return data.map((json) => Student.fromJson(json)).toList();
        }
        return []; // Empty but valid response
      } else {
        throw ApiException(
          'Failed to fetch Students: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
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

  Future<AssignmentClass> createAssignment (String token, AssignmentClass assignment)async{
    final url = Uri.parse('$_baseUrl/assignments');
    try{
      final Map<String, dynamic> data = assignment.toJson();
      final response = await http.post(
        url,
        headers:{
          "Authorization":'Bearer $token',
          "Content-Type": "application/json",
          "Accept":"application/json"
        },
        body: jsonEncode(data),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 401) {
        // print("Unauthorized - invalid token");
        throw UnauthorizedException();
      }

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data != null) {
          return AssignmentClass.fromJson(data);
        }
        return AssignmentClass();
      }

      if (response.statusCode == 422) {
        throw ValidationException();
      }

      final responseBody = jsonDecode(response.body);
      throw ApiException(
        responseBody['message'] ?? 'Failed to create assignment',
        statusCode: response.statusCode,
      );
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
    } on ValidationException {
      rethrow;
    } catch (e) {
      // print("Unexpected error in getProfile: $e");
      // if (e is ApiException) rethrow;
      // throw ApiException('Unexpected error: $e');
      rethrow;
    }
  }

  Future<List<AssignmentClass>?> getAssignments(String token) async {
    final url = Uri.parse('$_baseUrl/assignments');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      print("response.statusCode: ${response.statusCode}");

      if(response.statusCode == 401){
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && data is List) {
          return data.map((json) => AssignmentClass.fromJson(json)).toList();
        }
        return [];
      } else {
        throw ApiException(
          'Failed to fetch Assignment: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
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

  Future<Student> getStudentDashboard (String token) async {
    final url = Uri.parse('$_baseUrl/student/dashboard');
    try{
      final response = await http.get(
        url,
        headers: {
          'Authorization':'Bearer $token',
          'Access':'application/json'
        }
      ).timeout(Duration(seconds: 10));
      print("response.statusCode: ${response.statusCode}");
      // printJson(response.body, "student dashboard");
      // print("getStudentDashboard: ${response.statusCode}");
      if (response.statusCode == 401){
        throw UnauthorizedException();
      }
      
      if(response.statusCode == 200){
        final data = jsonDecode(response.body);
        return Student.fromJson(data);
      }
      return Student();

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


  Future<bool> markAsComplete({required String token, required int id}) async {
    final url = Uri.parse(
      '$_baseUrl/student/assignments/$id/complete'
    ); // Assuming your endpoint is /api/classes

    // 1. Construct the complete request body Map
    final Map<String, dynamic> requestBody = {
      "notes": "Completed successfully!",
    };

    try {
      final response = await http.post(
        url,
        headers: {
          // 🚨 CRITICAL: Include the Bearer token in the Authorization header
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody), // Encode the whole Map to JSON
      ).timeout(const Duration(seconds: 10));

      print(response.statusCode);

      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
        print('marked successfully!');
        return true;
      }

      if (response.statusCode == 422) {
        throw ValidationException();
      }

      final responseBody = jsonDecode(response.body);
      throw ApiException(
        responseBody['message'] ?? 'Failed to mark the assignment as complete',
        statusCode: response.statusCode,
      );
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
    } on ValidationException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

//   Future<List<Student>?> getStudentsByClass(String token, int classId)async{
//     final url = Uri.parse('$_baseUrl/classes');
//     try{
//       print("getStudentsByClass");
//       final response = await http.get(
//         url,
//         headers: {
//           'Authorization':'Bearer $token',
//           'Access':'application/json'
//         }
//       );
//       if(response.statusCode == 200){
//         final data = jsonDecode(response.body);
//         // print(data[classId]['class']['students']);
//         final studentsList = data[classId]['class']['students'] as List;
//         // print(studentsList);
//         return studentsList.map((json)=> Student.fromJson(json)).toList();
//       }else{
//         print("Fetch students Failed: ${response.statusCode}");
//         return null;
//       }
//     }catch(e){
//       print("Network Error: $e");
//     }
//   }
}
