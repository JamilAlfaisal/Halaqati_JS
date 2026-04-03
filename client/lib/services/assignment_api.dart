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

class AssignmentApi extends BaseApi{

  Future<Assignment> createAssignment (
      {
        required String classId,
        required String token,
        required String title,
        required String description,
        required String dueDate,
        required List<String> studentsIds,
        required List<String> pages,
        required String type,
      }
      )async{
    final url = Uri.parse('$baseUrl/assignment/create/${classId}');
    try{
      final Map<String, dynamic> data = {
        "title": title,
        "description":description,
        "dueDate":dueDate,
        "studentsIds":studentsIds,
        "pages": pages,
        "type": type
      };
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
          return Assignment.fromJson(data);
        }
        return Assignment.emptyAssignment();
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
      throw NetworkException();
    } on TimeoutException {
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

  Future<void> deleteAssignment(String token, String assignmentId) async {
    final url = Uri.parse('$baseUrl/assignment/delete/$assignmentId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) throw UnauthorizedException();

      if (response.statusCode != 200 && response.statusCode != 204) {
        final responseBody = jsonDecode(response.body);
        throw ApiException(
          responseBody['message'] ?? 'Failed to delete assignment',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Assignment> getAssignmentDetails(String token, String assignmentId) async {
    final url = Uri.parse('$baseUrl/assignment/details/$assignmentId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Assignment assignment = Assignment.fromJson(data);
        return assignment;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ApiException('Failed to fetch details', statusCode: response.statusCode);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateAssignment({
    required String token,
    required String id,
    required String title,
    required String description,
    required String dueDate,
    required List<int> pages,
    required String type,
    required List<int> studentsIds,
  }) async {
    final url = Uri.parse('$baseUrl/assignment/update/$id');

    final Map<String, dynamic> requestBody = {
      "title": title,
      "description": description,
      "dueDate": dueDate,
      "type": type,
      "pages": pages,
      "studentsIds": studentsIds,
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


      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      if (response.statusCode == 422) {
        throw ValidationException();
      }

      final responseBody = jsonDecode(response.body);
      throw ApiException(
        responseBody['message'] ?? 'Failed to update assignment',
        statusCode: response.statusCode,
      );
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    } on UnauthorizedException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on ValidationException {
      rethrow;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List<Assignment>?> getAssignmentOneStudentIassignments(String token, String studentId) async {
    final url = Uri.parse('$baseUrl/assignment/get_student_assignment/${studentId}');

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
          return data.map((json) => Assignment.fromJson(json)).toList();
        }else if(data != null && data["assignments"] is List ){
          final List<dynamic> list = data["assignments"];
          final List<Assignment> assignments =  list.map((json) {
            return Assignment.fromJson(json);
          }).toList();
          return assignments;
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


}