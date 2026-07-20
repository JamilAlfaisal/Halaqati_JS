import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/grade_model.dart';
import 'package:http/http.dart' as http;
import 'package:halqati/services/base_api.dart';
import 'package:halqati/models/cumulative_grade_model.dart'; // Adjust path

class GradesApi extends BaseApi {

  /// Fetches the cumulative grade, total points, and grade history
  Future<StudentGradeReportModel> getStudentGrades(
        {
          required String token,
          required String studentId,
          required String classId,
          int offset = 0,
          int limit = 10
        }
      ) async {
    final url = Uri.parse('$baseUrl/grades/get_grades/$studentId/class/$classId?offset=${offset}&limit=${limit}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) throw UnauthorizedException();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["data"] != null) {
          return StudentGradeReportModel.fromJson(data["data"]);
        }

        return StudentGradeReportModel.empty();
      } else {
        throw ApiException(
            'Failed to fetch grades',
            statusCode: response.statusCode
        );
      }
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> addGrade({
    required String token,
    required String studentId,
    required String classId,
    String? assignmentId,
    required double score,
    required int weight,
    int? card,
    String? description,
  }) async {
    final url = Uri.parse('$baseUrl/grades/set_grade');

    final Map<String, dynamic> requestBody = {
      "studentId": studentId,
      "classId": classId,
      "assignmentId": assignmentId,
      "score": score,
      "weight": weight,
      "card": card,
      "description": description,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 403) {
        // Specifically for teachers-only restriction
        throw ApiException('Forbidden: Only teachers can set grades', statusCode: 403);
      } else if (response.statusCode == 422 || response.statusCode == 400) {
        throw ValidationException();
      }
      throw ApiException('Failed to set grade', statusCode: response.statusCode);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    } catch (e) {
      rethrow;
    }
  }


  Future<void> updateGrade({
    required String token,
    required GradeModel grade,
    required String studentId,
    String? assignmentId,
    required String classId,
  }) async {
    final url = Uri.parse('$baseUrl/grades/update_grade');
    print("trying to update grades api");
    // Merging the grade data with the required student/class context
    final Map<String, dynamic> requestBody = {
      ...grade.toJson(),
      "gradeId": grade.id,
      "studentId": studentId,
      "classId": classId,
      "assignmentId": assignmentId,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) throw UnauthorizedException();

      if (response.statusCode != 200) {
        throw ApiException(
            'Failed to update grade analytics',
            statusCode: response.statusCode
        );
      }
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteGrade({required String token, required String gradeId}) async {
    final url = Uri.parse('$baseUrl/grades/delete_grade');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "gradeId": gradeId,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) throw UnauthorizedException();

      if (response.statusCode != 200) {
        throw ApiException(
            'Failed to delete grade and sync analytics',
            statusCode: response.statusCode
        );
      }
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    } catch (e) {
      rethrow;
    }
  }

}