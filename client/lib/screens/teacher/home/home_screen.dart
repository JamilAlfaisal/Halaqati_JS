import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:halqati/widgets/lists/halaqat_list.dart';
import 'package:halqati/widgets/buttons/floating_button_icon.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/main.dart';
import 'package:halqati/models/halaqa_class.dart';



class HomeScreen extends ConsumerStatefulWidget{
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with RouteAware{

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    ref.refresh(classesProvider);
  }

  @override
  Widget build(BuildContext context) {
    var classesAsync = ref.watch(classesProvider);
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = kToolbarHeight;

    // ref.listen<AsyncValue<List<HalaqaClass?>>>(
    //   classesProvider,
    //       (previous, next) {
    //     next.whenOrNull(
    //       error: (error, _) {
    //         if (error is UnauthorizedException) {
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             SnackBar(
    //               content: Text('Session expired. Please login again.'.tr()),
    //               duration: const Duration(seconds: 3),
    //             ),
    //           );
    //         }
    //       },
    //     );
    //   },
    // );

    return Scaffold(
      appBar: AppbarWithLogo(text: "home_screen.halaqati".tr()),
      floatingActionButton: FloatingButtonIcon(
        onPressed: (){
          Navigator.of(context).pushNamed("/add_halaqah_screen");
        }, text:'home_screen.create'.tr()
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30,vertical: 20),
        child: classesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
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
                    onPressed: () => ref.invalidate(classesProvider),
                    child: Text("home_screen.retry".tr()),
                  ),
                ],
              ),
            );
          },
          data: (halaqat){
            if (halaqat == null || halaqat.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async {
                  classesAsync = ref.refresh(classesProvider);
                  await Future.delayed(Duration(seconds: 1));
                },
                child: ListView(
                  children: [
                    Padding(
                        padding: EdgeInsetsGeometry.fromLTRB(0,(screenHeight/2)-appBarHeight,0,0),
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
            return RefreshIndicator(
              onRefresh: ()async{
                ref.refresh(classesProvider);
                // await Future.delayed(Duration(seconds: 1));
              },
              child: ListView.builder(
                itemCount: halaqat.length,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return HalaqatList(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        '/halaqah_bottom_bar',
                      );
                      ref.read(selectedClassIdProvider.notifier).select(halaqat[index].id??0);
                    },
                    title: halaqat[index].name!,
                    studentNumber: halaqat[index].studentCount,
                  );
                },
              ),
            );
          },
        )
      ),
    );
  }
}