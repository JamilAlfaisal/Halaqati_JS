import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/provider/teacher_providers/assignment_provider.dart';
import 'package:halqati/provider/teacher_providers/events_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/buttons/floating_button_icon.dart';
import 'package:halqati/widgets/lists/assignment_list.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {



  @override
  Widget build(BuildContext context) {

    final asyncEvents = ref.watch(eventProvider);
    return Scaffold(
      floatingActionButton: FloatingButtonIcon(
        onPressed: (){
          Navigator.of(context).pushNamed("/add_event_screen");
      }, text: "Add Event"
    ),
      appBar: AppbarWithButton(
          text: "event_details_screen.event_details".tr(),
          addBackButton: true
      ),
      body: asyncEvents.when(
        data: (events){
          print("events now is list");
          print(events);
          if(events == null){
            return Center(
              child: Text(
                'halaqah_details_screen.error_loading'.tr(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
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
                        onDelete: (){
                          ref.read(eventProvider.notifier).deleteEvent(events[index].id);
                        }
                      );
                    },
                  ),
                ),
              ],
            ),
          );

        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, stack) {
          print("error in the event screen: ${e}");
          if (e is UnauthorizedException) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Error loading events",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async{
                    ref.invalidate(eventProvider);
                    await ref.refresh(eventProvider.future);
                  },
                  child: Text("home_screen.retry".tr()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
