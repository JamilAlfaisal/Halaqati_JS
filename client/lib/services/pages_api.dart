import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:http/http.dart' as http;
import 'package:halqati/services/base_api.dart';
import 'package:halqati/models/juz_model.dart'; // Adjust path

class PagesApi extends BaseApi {

  Future<JuzModel> getPagesByChapter({
    required String token,
    required String studentId,
    required String chapter,
  }) async {
    final url = Uri.parse('$baseUrl/pages/pages_by_juz');

    final Map<String, dynamic> requestBody = {
      "studentId": studentId,
      "chapter": chapter,
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["data"] != null) {
          return JuzModel.fromJson(data["data"]);
        }

        return JuzModel.empty();
      } else {
        throw ApiException(
            'Failed to fetch chapter pages',
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

  Future<bool> addMemorizedPage({
    required String token,
    required String studentId,
    required int pageNumber,
    required String classId,
  }) async {
    final url = Uri.parse('$baseUrl/pages/memorize');

    final Map<String, dynamic> requestBody = {
      "studentId": studentId,
      "pageNumber": pageNumber,
      "classId": classId,
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
      } else if (response.statusCode == 400 || response.statusCode == 422) {
        throw ValidationException();
      }

      throw ApiException(
          'Failed to mark page as memorized',
          statusCode: response.statusCode
      );
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> updateReviewDate({
    required String token,
    required String studentId,
    required int pageNumber,
    required String classId,
  }) async {
    final url = Uri.parse('$baseUrl/pages/review');

    final Map<String, dynamic> requestBody = {
      "studentId": studentId,
      "pageNumber": pageNumber.toString(), // Matching your sample JSON string type
      "classId": classId,
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 404) {
        throw ApiException('Page record not found to review', statusCode: 404);
      }

      throw ApiException(
          'Failed to update review date',
          statusCode: response.statusCode
      );
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> unselectMemorizedPage({
    required String token,
    required String studentId,
    required int pageNumber,
  }) async {
    final url = Uri.parse('$baseUrl/pages/unselect_memorized');

    final Map<String, dynamic> requestBody = {
      "studentId": studentId,
      "pageNumber": pageNumber.toString(), // Matches your sample JSON string type
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

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else if (response.statusCode == 404) {
        throw ApiException('Memorization record not found', statusCode: 404);
      }

      throw ApiException(
          'Failed to unselect page',
          statusCode: response.statusCode
      );
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    } catch (e) {
      rethrow;
    }
  }

}