
import 'dart:convert';

import 'package:halqati/models/about_us_models.dart';
import 'package:halqati/services/base_api.dart';
import 'package:http/http.dart' as http;

class AboutUsApi  extends BaseApi{
  Future<AboutUs> fetchAboutContent() async {
    final response = await http.get(Uri.parse('$baseUrl/about_us'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return AboutUs.fromJson(data);
    } else {
      throw Exception('Failed to load About Us data');
    }
  }
}