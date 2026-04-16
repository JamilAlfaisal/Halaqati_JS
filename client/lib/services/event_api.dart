import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/FeedItem.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/event.dart';
import 'package:http/http.dart' as http;
import 'package:halqati/services/base_api.dart';

class EventApi extends BaseApi{

  Future<List<Event>> getEvents(String token, String classId
      ,{int offset = 0, int limit = 10}) async {
    final url = Uri.parse(
      '$baseUrl/event/get_teacher_events/$classId?offset=$offset&limit=$limit'
    );

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
        final  data = jsonDecode(response.body);
        final eventsJsonList = data["events"]??[];
        if (eventsJsonList != null && eventsJsonList is List){
          return eventsJsonList.map((json) => Event.fromJson(json)).toList();
        }
        return [];
      } else {
        throw ApiException('Failed to fetch events', statusCode: response.statusCode);
      }
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEvent(String token, String eventId) async {
    final url = Uri.parse('$baseUrl/event/delete/$eventId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      if (response.statusCode == 401) throw UnauthorizedException();
      if (response.statusCode != 204) {
        throw ApiException('Failed to delete event', statusCode: response.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEvent({required String token, required Event event}) async {
    final url = Uri.parse('$baseUrl/event/update/${event.id}');
    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(event.toJson()),
      );

      if (response.statusCode == 401) throw UnauthorizedException();
      if (response.statusCode != 200) {
        throw ApiException('Failed to update event', statusCode: response.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Event> getEventDetails(String token, String eventId) async {
    final url = Uri.parse('$baseUrl/event/details/$eventId');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401) throw UnauthorizedException();

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Event.fromJson(data);
      } else {
        throw ApiException('Failed to load event details', statusCode: response.statusCode);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> createEvent({
    required String token,
    required String title,
    required String description,
    required String dueDate,
    required String classId,
  }) async {
    final url = Uri.parse('$baseUrl/event/create/${classId}');

    final Map<String, dynamic> requestBody = {
      "title": title,
      "description": description,
      "dueDate": dueDate,
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
      } else if (response.statusCode == 422) {
        throw ValidationException();
      }


      throw ApiException('Failed to create event', statusCode: response.statusCode);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getStudentFeed(String token) async {
    final assignmentUrl =
    Uri.parse('$baseUrl/assignment/get_student_assignment');
    final eventUrl =
    Uri.parse('$baseUrl/event/get_student_events');

    try {
      final responses = await Future.wait([
        http.get(
          assignmentUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
        http.get(
          eventUrl,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      ]).timeout(const Duration(seconds: 10));

      final assignmentResponse = responses[0];
      final eventResponse = responses[1];

      if (assignmentResponse.statusCode == 401 ||
          eventResponse.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (assignmentResponse.statusCode != 200 ||
          eventResponse.statusCode != 200) {
        throw ApiException(
          'Failed to fetch student feed',
          statusCode: assignmentResponse.statusCode,
        );
      }
      final assignmentData = jsonDecode(assignmentResponse.body);
      final assignments = ((assignmentData['assignments'] ?? []) as List)
          .map((e) => Assignment.fromJson(e))
          .toList();

      final eventData = jsonDecode(eventResponse.body);
      final events = ((eventData['events'] ?? []) as List)
          .map((e) => Event.fromJson(e))
          .toList();

      final List<dynamic> feed = [
        ...assignments,
        ...events,
      ];

      feed.sort((a, b) {
        DateTime aDate;
        DateTime bDate;

        if (a is Assignment) {
          aDate = a.createdDate;
        } else if (a is Event) {
          aDate = a.createdDate;
        } else {
          aDate = DateTime.now();
        }

        if (b is Assignment) {
          bDate = b.createdDate;
        } else if (b is Event) {
          bDate = b.createdDate;
        } else {
          bDate = DateTime.now();
        }

        return bDate.compareTo(aDate);
      });

      return feed;
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException();
    } on UnauthorizedException {
      rethrow;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  Future<List<FeedItem>> getFeed(
      String token, {
        int offset = 0,
        int limit = 10,
      }) async {
    final url = Uri.parse(
      '$baseUrl/event/get_student_feed?offset=$offset&limit=$limit',
    );

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

        final List list = data['feed'] ?? [];

        return list.map((e) => FeedItem.fromJson(e)).toList();
      } else {
        throw ApiException(
          'Failed to fetch feed',
          statusCode: response.statusCode,
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