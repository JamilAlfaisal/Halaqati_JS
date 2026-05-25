import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/attendance.dart';
import 'package:halqati/models/attendance_state.dart';
import 'package:http/http.dart' as http;
import 'package:halqati/services/base_api.dart';

class AttendanceApi extends BaseApi{

  Future<List<Attendance>> getAttendances({
    required String token,
    required String classId,
    int offset = 0,
    int limit = 10,
  }) async {
    final url = Uri.parse('$baseUrl/attendance/get/$classId?offset=$offset&limit=$limit');

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
        if (data['attendance'] != null && data['attendance'] is List) {
          List<Attendance> attendances =
          (data['attendance'] as List)
              .map((json) => Attendance.fromJson(json))
              .toList();
          return attendances;
        }
        return [];
      } else {
        throw ApiException(
          'Failed to fetch attendances: ${response.statusCode}',
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

  Future<bool> takeAttendance({
    required String token,
    required String classId,
    required List<int> studentIds,
  }) async {
    final url = Uri.parse('$baseUrl/attendance/take/$classId');

    final Map<String, dynamic> requestBody = {
      "studentIds": studentIds,
    };

    try {
      final response = await http
          .post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestBody),
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      if (response.statusCode == 422) {
        throw ValidationException();
      }

      final responseBody = jsonDecode(response.body);

      throw ApiException(
        responseBody['message'] ?? 'Failed to take attendance',
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
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<Attendance> getAttendanceDetails({
    required String token,
    required String attendanceId,

  }) async {
    final url = Uri.parse('$baseUrl/attendance/details/$attendanceId');

    try {
      final response = await http
          .get(
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

        if (data != null) {
          return Attendance.fromJson(data["attendanceDetails"]);
        }

        throw ApiException("Invalid attendance details response");
      }

      throw ApiException(
        'Failed to fetch attendance details: ${response.statusCode}',
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
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<bool> updateAttendance({
    required String token,
    required String attendanceId,
    required List<int> studentIds,
  }) async {
    final url = Uri.parse('$baseUrl/attendance/update/$attendanceId');

    final Map<String, dynamic> requestBody = {
      "studentIds": studentIds,
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
      )
          .timeout(const Duration(seconds: 10));

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
        responseBody['message'] ?? 'Failed to update attendance',
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
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<bool> deleteAttendance({
    required String token,
    required String attendanceId,
  }) async {
    final url = Uri.parse('$baseUrl/attendance/delete/$attendanceId');

    try {
      final response = await http
          .delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      }

      throw ApiException(
        'Failed to delete attendance: ${response.statusCode}',
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
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<List<AttendanceStats>> getAttendanceStats({
    required String token,
    required String classId,
    String? fromDate, // optional
  }) async {

    final url = Uri.parse(
        '$baseUrl/attendance/stats/$classId'
            '${fromDate != null ? "?fromDate=$fromDate" : ""}'
    );

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

        if (data['stats'] != null && data['stats'] is List) {
          return (data['stats'] as List)
              .map((json) => AttendanceStats.fromJson(json))
              .toList();
        }

        return [];
      } else {
        throw ApiException(
          'Failed to fetch attendance stats: ${response.statusCode}',
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
