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

class ApiService {
  // 💡 IMPORTANT: Use the correct IP for your emulator/device
  // Android Emulator: 10.0.2.2
  // iOS Simulator: 127.0.0.1 (or localhost)
  // Physical Device (if on same network): Your PC's local IP (e.g., 192.168.1.10)
  static const String _baseUrl = 'https://unnotional-jayme-gamophyllous.ngrok-free.dev/api';

  Future <Map<String, dynamic>?> login(String phone, String pin) async {

    final url = Uri.parse('$_baseUrl/auth/login/user');

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
    final url = Uri.parse('$_baseUrl/auth/auth_me/user');
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
      // ✅ CHECK STATUS CODE FIRST!
      if (response.statusCode == 401) {
        print("Unauthorized - invalid token");
        throw UnauthorizedException();
      }

      // ✅ Only decode JSON if status is success
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

  // Future<void> logout(String token) async {
  //   final url = Uri.parse('$_baseUrl/auth/logout');
  //
  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Accept': 'application/json',
  //       },
  //     ).timeout(const Duration(seconds: 10));
  //
  //     // ✅ CHECK STATUS CODE FIRST!
  //     if (response.statusCode == 401) {
  //       // await _clearLocalData();
  //       return;
  //     }
  //
  //     // ✅ Only decode JSON if status is success
  //     if (response.statusCode == 200) {
  //       // await _clearLocalData();
  //       print("Logout successful");
  //     } else {
  //       throw ApiException('Failed to logout', statusCode: response.statusCode);
  //     }
  //
  //   } on SocketException {
  //     print("Network error - no internet connection");
  //     throw NetworkException();
  //   } on NetworkException {
  //     rethrow;
  //   } catch (e) {
  //     print("Unexpected error in logout: $e");
  //     if (e is ApiException) rethrow;
  //     throw ApiException('Unexpected error: $e');
  //   }
  // }

  Future<bool> createClass({
    required String token,
    required String name,
    required String description,
    required String roomNumber,
    required List<int> scheduleDays,
    required String startTime,
    required String endTime,
  }) async {
    final url = Uri.parse('$_baseUrl/class/create');

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
    final url = Uri.parse('$_baseUrl/class/get_teacher_classes');
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
    final url = Uri.parse('$_baseUrl/class/details/$id');

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
    final url = Uri.parse('$_baseUrl/class/delete/$classId');

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

    final url = Uri.parse('$_baseUrl/class/update/$id');

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

  Future<List<Student>> getStudents(String token,String classId) async {
    final url = Uri.parse('$_baseUrl/student_class/get/$classId');

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
        final students = data["students"]??[];
        if (students != null && students is List) {
          return students.map((json) => Student.fromJson(json)).toList();
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

  Future<bool> addStudentToClass({
    required String token,
    required String classId,
    required String phone,
  }) async {
    // Matches your structure: {{base_url}}/student_class/add/{{class_id}}
    final url = Uri.parse('$_baseUrl/student_class/add/$classId');

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
    final url = Uri.parse('$_baseUrl/student_class/remove/$classId');

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
      print("response.statusCode: ${response.statusCode}");
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

  Future<bool> updateStudentJuz({
    required String token,
    required String studentId,
    required List<String> juzList,
  }) async {
    final url = Uri.parse('$_baseUrl/update_student/juz/$studentId');

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
    final url = Uri.parse('$_baseUrl/assignment/create/${classId}');
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
        return Assignment(
          id: '',
          title: '',
          dueDate: DateTime(2017, 9, 7, 17, 30),
          type: '',
          description: '',
          pages: [],
          createdDate: DateTime(2017, 9, 7, 17, 30),
          students: [],
          teacher: Teacher(
            id: "",
            name: "",
            email: "",
            phone: "", role: '', dob: DateTime.now(), createdAt: DateTime.now(), picProfile: '', createdClasses: [],
          ),
          halaqaClass: ClassModel(
            id: "",
            teacher:  Teacher(
              id: "",
              name: "",
              email: "",
              phone: "", role: '', dob: DateTime.now(), createdAt: DateTime.now(), picProfile: '', createdClasses: [],
            ),
            name: "",
            description: "",
            location: "",
            startTime: "",
            endTime: "",
            days: const [],
            students: const [],
            events: const [],
            assignments: const [],
            attendanceRecords: const [],
          )
        );
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

  Future<void> deleteAssignment(String token, String assignmentId) async {
    final url = Uri.parse('$_baseUrl/assignment/delete/$assignmentId');

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
    final url = Uri.parse('$_baseUrl/assignment/details/$assignmentId');
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
        // printJson(data, "getAssignmentDetails");
        final Assignment assignment = Assignment.fromJson(data);
        // print("assignment instance: ${assignment}");
        return assignment;
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      }
      throw ApiException('Failed to fetch details', statusCode: response.statusCode);
    } catch (e) {
      print("getAssignmentDetailsError: ${e}");
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
    final url = Uri.parse('$_baseUrl/assignment/update/$id');

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

      print("response: ${response}");

      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Assignment updated successfully!');
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
      print(e);
      rethrow;
    }
  }

  Future<List<Assignment>?> getAssignmentOneStudentIassignments(String token, String studentId) async {
    final url = Uri.parse('$_baseUrl/assignment/get_student_assignment/${studentId}');

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
          return data.map((json) => Assignment.fromJson(json)).toList();
        }else if(data != null && data["assignments"] is List ){
          print("data is not null and it is list");
          final List<dynamic> list = data["assignments"];
          final List<Assignment> assignments =  list.map((json) {
            return Assignment.fromJson(json);
          }).toList();
          print("api service: ${assignments}");
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

  Future<Student> getStudentDashboard (String token) async {
    final url = Uri.parse('$_baseUrl/auth/auth_me/user');
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
        printJson(data, "this is the students");
        return Student.fromJson(data["user"]);
      }
      return Student(id: '', name: '', email: '', role: '', dob: DateTime.now(), createdAt: DateTime.now(), picProfile: '', phone: '', memorizedJuz: [], enrolledClasses: []);

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
      '$_baseUrl/assignment/mark_as_complete_uncomplete/$id'
    );

    final Map<String, dynamic> requestBody = {
      "notes": "Completed successfully!",
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

  Future<List<Event>> getEvents(String token, String classId) async {
    final url = Uri.parse('$_baseUrl/event/get_teacher_events/$classId');

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
        print("get all events: ${data}");
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

  // Inside your ApiService class:

  Future<void> deleteEvent(String token, String eventId) async {
    final url = Uri.parse('$_baseUrl/event/delete/$eventId');
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
    final url = Uri.parse('$_baseUrl/event/update/${event.id}');
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
    final url = Uri.parse('$_baseUrl/event/details/$eventId');
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
        printJson(data, "getting the event details");
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
    // Add other fields as needed (e.g. priority, category)
  }) async {
    final url = Uri.parse('$_baseUrl/event/create/${classId}');

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

  Future<List<Attendance>> getAttendances({
    required String token,
    required String classId,
  }) async {
    final url = Uri.parse('$_baseUrl/attendance/get/$classId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      print("get attendance: ${response.statusCode}");

      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['attendance'] != null && data['attendance'] is List) {
          print("attendance we got: ${data['attendance']}");

          List<Attendance> attendances =
          (data['attendance'] as List)
              .map((json) => Attendance.fromJson(json))
              .toList();

          return attendances;
        }

        print("getting empty attendance list");
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
    final url = Uri.parse('$_baseUrl/attendance/take/$classId');

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
        print("Attendance submitted successfully");
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
    final url = Uri.parse('$_baseUrl/attendance/details/$attendanceId');

    try {
      final response = await http
          .get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      print("response.statusCode: ${response.statusCode}");

      if (response.statusCode == 401) {
        throw UnauthorizedException();
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data != null) {

          return Attendance.fromJson(data["attendacneDetails"]);
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
    final url = Uri.parse('$_baseUrl/attendance/update/$attendanceId');

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
      print("response.statusCode: ${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 204) {
        print("Attendance updated successfully");
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

  Future<List<ClassModel>> getStudentClasses(String token) async {
    final url = Uri.parse('$_baseUrl/class/get_student_classes');

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
          print("student classes we got: ${data['classes']}");

          List<ClassModel> classes = (data['classes'] as List)
              .map((json) => ClassModel.fromJson(json))
              .toList();

          return classes;
        }

        print("getting empty student classes list");
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

  Future<List<dynamic>> getStudentFeed(String token) async {
    final assignmentUrl =
    Uri.parse('$_baseUrl/assignment/get_student_assignment');
    final eventUrl =
    Uri.parse('$_baseUrl/event/get_student_events');

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
      // final assignments = [];
      final assignmentData = jsonDecode(assignmentResponse.body);
      final assignments = ((assignmentData['assignments'] ?? []) as List)
          .map((e) => Assignment.fromJson(e))
          .toList();
      // final events = [];
      final eventData = jsonDecode(eventResponse.body);
      final events = ((eventData['events'] ?? []) as List)
          .map((e) => Event.fromJson(e))
          .toList();

      final List<dynamic> feed = [
        ...assignments,
        ...events,
      ];

      feed.sort((a, b) => b.createdDate.compareTo(a.createdDate));

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
