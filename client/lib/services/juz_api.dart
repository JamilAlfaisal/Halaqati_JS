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

class JuzApi extends BaseApi{

  Future<bool> updateStudentJuz({
    required String token,
    required String studentId,
    required List<String> juzList,
  }) async {
    final url = Uri.parse('$baseUrl/update_student/juz/$studentId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "memorized_juz": juzList,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      final responseBody = jsonDecode(response.body);
      throw ApiException(
        responseBody['message'] ?? 'Failed to update Juz',
        statusCode: response.statusCode,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> markAsComplete({required String token, required int id}) async {
    final url = Uri.parse(
        '$baseUrl/assignment/mark_as_complete_uncomplete/$id'
    );

    final Map<String, dynamic> requestBody = {
      "notes": "Completed successfully!",
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

      print(response.statusCode);

      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
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

  Future<bool> markAsRead({required String token, required int id}) async {
    final url = Uri.parse(
        '$baseUrl/assignment/mark_as_read/$id'
    );

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print(response.statusCode);

      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
        return true;
      }

      if (response.statusCode == 422) {
        throw ValidationException();
      }

      final responseBody = jsonDecode(response.body);
      throw ApiException(
        responseBody['message'] ?? 'Failed to mark assignment as read',
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

}