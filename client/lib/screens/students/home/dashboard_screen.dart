import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/provider/student_providers/student_classes_provider.dart';
import 'package:halqati/provider/student_providers/student_provider.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:halqati/widgets/empty_state_view.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/lists/class_list_item.dart';
import 'package:halqati/widgets/loading_widget.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {


  @override
  Widget build(BuildContext context) {

    final classesAsync = ref.watch(studentClassesProvider);


    return Scaffold(
      appBar: AppbarWithLogo(text: "classes".tr()),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(studentClassesProvider);
          await Future.delayed(Duration(seconds: 1));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 200,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16))
                ),
                child: Image.asset(
                  'assets/images/alhamidi.png',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            classesAsync.when(
              data: (classes){
                if (classes == null || (classes.length) == 0) {
                  return Expanded(child: EmptyStateView());
                }
                return Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      top: 20,
                      left: 16,
                      right: 16,
                      bottom: MediaQuery.of(context).padding.bottom
                    ),
                    itemCount: classes.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ClassListItem(
                        onTap: (){
                          ref.read(selectedClassIdProvider.notifier).select(classes[index].id);
                          Navigator.of(context).pushNamed("/halaqa_details_screen");
                        },
                        name: classes[index].name,
                        description: classes[index].description,
                        room: classes[index].location,
                      );
                    },
                  ),
                );
              },
              loading: () => Expanded(child: LoadingWidget()),
              error: (e, stack) {
                if (e is UnauthorizedException) {
                  return const Center(child: CircularProgressIndicator());
                }

                return CustomErrorWidget(
                  providerToInvalidate: studentDashboard,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
