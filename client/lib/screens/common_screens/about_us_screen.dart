import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/provider/about_us_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/loading_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends ConsumerWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final aboutAsync = ref.watch(aboutDataProvider);
    // Check if current locale is Arabic
    bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppbarWithButton(text: "about_us".tr(), addBackButton: true),
      body: aboutAsync.when(
        data: (data) => RefreshIndicator(
          onRefresh: ()async {
            await ref.refresh(aboutDataProvider.future);
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
              right: 16,
              left: 16
            ),
            child: Html(
              // Dynamically select the content based on language
              data: isArabic ? data.arabicContent : data.englishContent,
              onLinkTap: (url, _, __) => _handleLaunch(url),
            ),
          ),
        ),
        loading: () =>  LoadingWidget(),
        error: (e, stack) {
          if (e is UnauthorizedException) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomErrorWidget(
            providerToInvalidate: aboutDataProvider,
          );
        },
      ),
    );
  }

  void _handleLaunch(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}