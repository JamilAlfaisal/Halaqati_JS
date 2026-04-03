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

class ClassesApi extends BaseApi{

  Future<bool> createClass({
    required String token,
    required String name,
    required String description,
    required String roomNumber,
    required List<int> scheduleDays,
    required String startTime,
    required String endTime,
  }) async {
    final url = Uri.parse('$baseUrl/class/create');

    // 1. Construct the complete request body Map
    final Map<String, dynamic> requestBody = {
      "name": name,
      "description": description,
      "location": roomNumber,
      "startTime":startTime,
      "endTime":endTime,
      "days":scheduleDays,
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


  Future<List<ClassModel>> getClasses(String token) async {
    final url = Uri.parse('$baseUrl/class/get_teacher_classes');
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
        if (data['classes'] != null && data['classes'] is List) {
          print("classes we got: ${data['classes']}");
          List<ClassModel> listHalaqatiClass =  (data['classes'] as List).map((json)
          => ClassModel.fromJson(json)
          ).toList();

          return listHalaqatiClass;
        }
        print("getting empty list");
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

  Future<ClassModel> getClass(String token, String id) async {
    final url = Uri.parse('$baseUrl/class/details/$id');

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
          return ClassModel.fromJson(data['class']);
        }
        return new ClassModel(
            id: "",
            name: "",
            description: '',
            location: '',
            startTime: '',
            endTime: '',
            days: [],
            students: [],
            events: [],
            assignments: [],
            attendanceRecords: [],
            teacher: Teacher(id: '', name: '', phone: '', email: '', role: '', dob: DateTime.now(), createdAt: DateTime.now(), picProfile: '', createdClasses: []

            )
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

  Future<void> deleteClass(String token, String classId) async {
    final url = Uri.parse('$baseUrl/class/delete/$classId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }
      if (response.statusCode == 204 || response.statusCode == 200) {
        print('Class $classId deleted successfully');
        return;
      }
      final responseBody = jsonDecode(response.body);
      throw ApiException(
        responseBody['message'] ?? 'Failed to delete class',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateClasses({
    required String token,
    required String name,
    required String description,
    required String roomNumber,
    required List<int> scheduleDays,
    required String startTime,
    required String endTime,
    required String id
  }) async {

    final url = Uri.parse('$baseUrl/class/update/$id');

    final Map<String, dynamic> requestBody = {
      "name": name,
      "description": description,
      "location": roomNumber,
      "startTime":startTime,
      "endTime":endTime,
      "days":scheduleDays
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));
      print("updateClasses: ${response.statusCode}");
      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
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

  Future<List<Student>> getStudents(String token,String classId) async {
    final url = Uri.parse('$baseUrl/student_class/get/$classId');

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
        final students = data["students"]??[];
        if (students != null && students is List) {
          return students.map((json) => Student.fromJson(json)).toList();
        }
        return [];
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
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<bool> addStudentToClass({
    required String token,
    required String classId,
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/student_class/add/$classId');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"phone": phone}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 404) {
        throw ApiException('Class not found', statusCode: 404);
      }

      final responseBody = jsonDecode(response.body);
      throw ApiException(
        responseBody['message'] ?? 'Failed to add student',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> removeStudentFromClass({
    required String token,
    required String classId,
    required String phone,
  }) async {
    final url = Uri.parse('$baseUrl/student_class/remove/$classId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"phone": phone}),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      final responseBody = jsonDecode(response.body);
      throw ApiException(
        responseBody['message'] ?? 'Failed to remove student',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ClassModel>> getStudentClasses(String token) async {
    final url = Uri.parse('$baseUrl/class/get_student_classes');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['classes'] != null && data['classes'] is List) {
          List<ClassModel> classes = (data['classes'] as List)
              .map((json) => ClassModel.fromJson(json))
              .toList();

          return classes;
        }

        return [];
      } else {
        throw ApiException(
          'Failed to fetch student classes: ${response.statusCode}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
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


}