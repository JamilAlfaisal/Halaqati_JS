import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/models/about_us_models.dart';
import 'package:halqati/services/about_us_api.dart';


final aboutServiceProvider = Provider((ref) => AboutUsApi());


final aboutDataProvider = FutureProvider<AboutUs>((ref) async {
  return ref.read(aboutServiceProvider).fetchAboutContent();
});