import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/teacher.dart';
import 'package:halqati/provider/student_providers/student_classes_provider.dart';
import 'package:halqati/provider/student_providers/student_provider.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:halqati/models/class_model.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';
import 'package:halqati/widgets/lists/class_list_item.dart';

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
      appBar: AppbarWithLogo(text: "student_app_bar.dashboard.title".tr()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: RefreshIndicator(
          onRefresh: () async {
            ref.refresh(studentDashboard);
            await Future.delayed(Duration(seconds: 1));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
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
              classesAsync.when(
                data: (classes){
                  if (classes == null) {
                    return SizedBox(
                      width: 200,
                      height: 100,
                      child: ListView(
                        children: [
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 50),
                              child: Center(
                                child: Text(
                                  "home_screen.no_halaqat".tr(),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              )
                          ),
                        ],
                      ),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        top: 20,
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
                loading: () => Expanded(child: const Center(child: CircularProgressIndicator())),
                error: (e, stack) {
                  if (e is UnauthorizedException) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Error loading halaqat",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        // ✅ Add retry button for errors
                        ElevatedButton(
                          onPressed: () => ref.invalidate(studentDashboard),
                          child: Text("home_screen.retry".tr()),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
