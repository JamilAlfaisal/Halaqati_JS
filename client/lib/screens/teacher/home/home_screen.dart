import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/widgets/appbar/appbar_with_logo.dart';
import 'package:halqati/widgets/empty_state_view.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/lists/halaqat_list.dart';
import 'package:halqati/widgets/buttons/floating_button_icon.dart';
import 'package:halqati/provider/teacher_providers/classes_provider.dart';
import 'package:halqati/main.dart';
import 'package:halqati/widgets/loading_widget.dart';



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

    return Scaffold(
      appBar: AppbarWithLogo(text: "classes".tr()),
      floatingActionButton: FloatingButtonIcon(
        onPressed: (){
          Navigator.of(context).pushNamed("/add_halaqah_screen");
        }, text:'create_class'.tr()
      ),
      body: classesAsync.when(
        loading: () => LoadingWidget(),
        error: (e, stack) {

          if (e is UnauthorizedException) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomErrorWidget(
            providerToInvalidate: classesProvider,
          );
        },
        data: (halaqat){
          if (halaqat == null || halaqat.length == 0) {
            return RefreshIndicator(
              onRefresh: () async {
                classesAsync = ref.refresh(classesProvider);
                await Future.delayed(Duration(seconds: 1));
              },
              child: EmptyStateView()
            );
          }
          return RefreshIndicator(
            onRefresh: ()async{
              ref.refresh(classesProvider);
              // await Future.delayed(Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: MediaQuery.of(context).padding.bottom + 10
              ),
              itemCount: halaqat.length,
              physics: const AlwaysScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return HalaqatList(
                  onTap: () {
                    ref.read(selectedClassIdProvider.notifier).select(halaqat[index].id);
                    ref.read(selectedClassNameProvider.notifier).setName(halaqat[index].name);
                    Navigator.of(context).pushNamed(
                      '/halaqah_bottom_bar',
                    );
                  },
                  title: halaqat[index].name,
                  studentNumber: halaqat[index].studentCount(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}