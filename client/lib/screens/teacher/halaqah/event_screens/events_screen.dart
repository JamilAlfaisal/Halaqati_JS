import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/provider/is_loading_more_provider.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/teacher_providers/events_provider.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_extra_button.dart';
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

  final isLoadingMore = false;

  @override
  Widget build(BuildContext context) {

    final asyncEvents = ref.watch(eventProvider);
    final String halaqahName = ref.watch(selectedClassNameProvider)??"name".tr();
    final isLoadingMore = ref.watch(isLoadingMoreProvider("events"));
    return Scaffold(

      appBar: AppbarExtraButton(
        text: halaqahName,
        addBackButton: true,
        icon: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.primary,
        ),
        onPress: () async {
          Navigator.of(context).pushNamed("/add_event_screen");
        },
      ),

      // floatingActionButton: FloatingButtonIcon(
      //     onPressed: (){
      //       Navigator.of(context).pushNamed("/add_event_screen");
      //   }, text: "${"add".tr()} ${"event".tr()}"
      // ),
      body: asyncEvents.when(
        data: (events){
          if(events == null || events.length == 0){
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(eventProvider);
              },
              child: EmptyStateView()
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
                    // controller: _scrollController,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                      top: 20,
                      left: 20,
                      right: 20
                    ),
                    itemCount: events.length + (ref.watch(eventProvider.notifier).hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= events.length) {
                        if (isLoadingMore || ref.watch(eventProvider).isLoading) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          );
                        }
                        return Center(
                          child: IconButton(
                            onPressed: () {
                              ref.read(eventProvider.notifier).loadMore(); // ✅ NO setState
                            },
                            icon: const Icon(Icons.expand_more),
                          ),
                        );
                      }
                      return AssignmentList(
                        title: events[index].title,
                        dueDate: HelperMethods.formatDate(events[index].dueDate),
                        onTap: (){

                          ref.read(selectedEventIdProvider.notifier).select(events[index].id);
                          Navigator.of(context).pushNamed("/event_details_screen");
                        },
                        onDelete: ref.watch(eventProvider).isLoading?null:() async {
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
