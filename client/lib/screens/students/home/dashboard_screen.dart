import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/models/teacher.dart';
import 'package:halqati/provider/student_providers/student_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:halqati/models/halaqa_class.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {

    final asyncStudentDashboard = ref.watch(studentDashboard);

    return Scaffold(
      appBar: AppbarWithLogo(text: "student_app_bar.dashboard.title".tr()),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            asyncStudentDashboard.when(
              data: (student){
                final HalaqaClass halaqaClass = student?.halaqaClass??HalaqaClass(name: "", id: 0);
                final Teacher teacher = student?.teacher ?? Teacher();
                final assignmentCount = student?.assignmentClass?.length??0;
                if (student == null) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.refresh(studentDashboard);
                      await Future.delayed(Duration(seconds: 1));
                    },
                    child: SizedBox(
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
                    ),
                  );
                }
                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.refresh(studentDashboard);
                      await Future.delayed(Duration(seconds: 1));
                    },
                    child: ListView(
                      children: [
                        SizedBox(height: 10,),
                        // ClassInfo(classInfo: student.halaqaClass,),
                        Text(
                          "${halaqaClass.name}",
                          style: Theme.of(context).textTheme.bodyLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 2,
                              children: [
                                Text(
                                  "${teacher.name}",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  "${halaqaClass.time}",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                            ElevatedDark(onPressed: (){
                              Navigator.of(context).pushNamed('/halaqa_details_screen');
                            }, text: 'dashboard_screen.more'.tr()),
                          ],
                        ),
                        Container(
                          height: 200,
                          margin: EdgeInsets.only(top: 10),
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(16))
                          ),
                          child: Image.asset(
                            'assets/images/quran.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                        SizedBox(height: 5,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'dashboard_screen.quran'.tr(),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  "${'dashboard_screen.assignment_count'.tr()}: $assignmentCount",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                            ElevatedDark(onPressed: (){}, text: 'dashboard_screen.read'.tr())
                          ],
                        ),
                      ],
                    ),
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
    );
  }
}
