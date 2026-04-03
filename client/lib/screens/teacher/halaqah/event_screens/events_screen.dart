import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/teacher_providers/assignment_provider.dart';
import 'package:halqati/provider/teacher_providers/events_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/buttons/floating_button_icon.dart';
import 'package:halqati/widgets/confirmation_dialog.dart';
import 'package:halqati/widgets/empty_state_view.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/widgets/lists/assignment_list.dart';
import 'package:halqati/widgets/loading_widget.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {



  @override
  Widget build(BuildContext context) {

    final asyncEvents = ref.watch(eventProvider);
    final String halaqahName = ref.watch(selectedClassNameProvider)??"name".tr();

    return Scaffold(
      floatingActionButton: FloatingButtonIcon(
        onPressed: (){
          Navigator.of(context).pushNamed("/add_event_screen");
      }, text: "${"add".tr()} ${"event".tr()}"
    ),
      appBar: AppbarWithButton(
          text: halaqahName,
          addBackButton: true
      ),
      body: asyncEvents.when(
        data: (events){
          if(events == null || events.length == 0){
            return EmptyStateView();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(eventProvider);
            },
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                      top: 20,
                      left: 20,
                      right: 20
                    ),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return AssignmentList(
                        title: events[index].title??"",
                        dueDate: HelperMethods.formatDate(events[index].dueDate)??"",
                        onTap: (){

                          ref.read(selectedEventIdProvider.notifier).select(events[index].id);
                          Navigator.of(context).pushNamed("/event_details_screen");
                        },
                        onDelete: () async {
                          final confirm = await showConfirmationDialog(
                            context: context,
                            title: "delete_event".tr(),
                            message: "delete_event_warning".tr(),
                            cancelText: "cancel".tr(),
                            confirmText: "confirm".tr(),
                            confirmColor: Colors.red,
                          );
                          if (confirm){
                            ref.read(eventProvider.notifier).deleteEvent(events[index].id);
                          }
                        }
                      );
                    },
                  ),
                ),
              ],
            ),
          );

        },
        loading: () => LoadingWidget(),
        error: (e, stack) {
          if (e is UnauthorizedException) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomErrorWidget(
            providerToInvalidate: eventProvider,
          );
        },
      ),
    );
  }
}
