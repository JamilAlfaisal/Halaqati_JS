import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

class CustomErrorWidget extends ConsumerWidget {
  final String? title;
  final String? buttonText;
  final ProviderBase? providerToInvalidate;

  const CustomErrorWidget({
    super.key,
    this.title,
    this.buttonText,
    this.providerToInvalidate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title ?? "error".tr(),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                print("method ha");
                if (providerToInvalidate != null) {
                  ref.invalidate(providerToInvalidate!);
                }
              },
              child: Text(buttonText ?? "home_screen.retry".tr()),
            ),
          ],
        ),
      ),
    );
  }
}