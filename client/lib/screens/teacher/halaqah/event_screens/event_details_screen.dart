import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/teacher_providers/events_provider.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';
import 'package:halqati/widgets/error_widget.dart';
import 'package:halqati/provider/teacher_providers/event_confirmations_provider.dart';
import 'package:halqati/widgets/loading_widget.dart';
import 'package:halqati/widgets/textfields/custome_date_picker.dart';
import 'package:halqati/widgets/textfields/text_area.dart';
import 'package:halqati/widgets/textfields/text_field_normal.dart';
import 'package:halqati/widgets/textfields/text_field_normal.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  TextEditingController title = TextEditingController();
  TextEditingController des = TextEditingController();
  TextEditingController date = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _initialized = false;
  bool _requireConfirmation = false;



  @override
  Widget build(BuildContext context) {
    final asyncEvent = ref.watch(eventDetailsProvider);
    final String halaqahName = ref.watch(selectedClassNameProvider)??"name".tr();

    void updateEvent() async {

      await ref.read(eventDetailsProvider.notifier).updateEventDetails(
        title: title.text,
        description: des.text,
        dueDate: date.text,
        confirmation: _requireConfirmation,
      );
      final state = ref.read(eventDetailsProvider);

      if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${"error".tr()}: ${state.error}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        ref.read(eventProvider.notifier).updateEvent(
          id: asyncEvent.value?.id??"0", title: title.text, description: des.text, dueDate: HelperMethods.parseDate(date.text)
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${"created_success".tr()}')),
        );
        Navigator.pop(context);
      }
    }


    return Scaffold(
      appBar: AppbarWithButton(
          text: halaqahName,
          addBackButton: true
      ),
      body: asyncEvent.when(
        data: (event){
          if (!_initialized && event != null) {
            _initialized = true;
            des.text = event.description;
            title.text = event.title;
            date.text = HelperMethods.formatDate(event.dueDate);
            _requireConfirmation = event.confirmation;
          }


          return RefreshIndicator(
            onRefresh: () async {
              _initialized = false;
              if (event?.id != null) {
                // Ensure confirmations reload correctly
                ref.invalidate(eventConfirmationsProvider(event!.id));
              }
              ref.invalidate(eventDetailsProvider);
              await ref.refresh(eventDetailsProvider.future);
            },
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                  right: 20,
                  left: 20,
                  top: 20
                ),
                children: [
                  TextFieldNormal(
                      hintText: "${"enter".tr()} ${"title".tr()}",
                      textController: title,
                      title: "title".tr()
                  ),
                  TextArea(
                      textController: des,
                      title: "des".tr()
                  ),
                  SizedBox(height: 20,),
                  CustomDatePicker(
                    label: "due_date".tr(),
                    onDateSelected: (selectedDate){
                      setState(() {
                        date.text = HelperMethods.formatDate(selectedDate);
                      });
                    },
                    selectedDate: HelperMethods.parseDate(date.text),
                  ),
                  SizedBox(height: 20,),
                  SwitchListTile(
                    title: Text(
                      "confirm_attendance".tr(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    activeColor: Theme.of(context).colorScheme.primary,
                    value: _requireConfirmation,
                    onChanged: (val) {
                      setState(() {
                        _requireConfirmation = val;
                      });
                    },
                  ),
                  SizedBox(height: 10,),
                    ElevatedDark(
                      onPressed: () {
                        updateEvent();
                      },
                      text: "update".tr(),
                      ability: !ref.watch(eventProvider).isLoading,
                    ),
                    const SizedBox(height: 30),
                    if (event?.confirmation == true) ...[
                      Text(
                        "confirmed_students".tr(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      ref.watch(eventConfirmationsProvider(asyncEvent.value?.id ?? "")).when(
                        data: (confirmations) {
                          if (confirmations.isEmpty) {
                            return Center(child: Text("no_data".tr()));
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: confirmations.length,
                            itemBuilder: (context, index) {
                              final conf = confirmations[index];
                              IconData icon;
                              Color color;
                              String statusText;
                              if (conf.status == true) {
                                icon = Icons.check_circle;
                                color = Theme.of(context).colorScheme.primary;
                                statusText = "yes_will_attend".tr();
                              } else if (conf.status == false) {
                                icon = Icons.cancel;
                                color = Colors.red;
                                statusText = "no_will_not_attend".tr();
                              } else {
                                icon = Icons.pending;
                                color = Colors.orange;
                                statusText = "pending".tr();
                              }

                              return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.grey.shade300,
                                    backgroundImage: conf.picProfile != null && conf.picProfile!.isNotEmpty
                                        ? NetworkImage(conf.picProfile!)
                                        : null,
                                    child: (conf.picProfile == null || conf.picProfile!.isEmpty)
                                        ? const Icon(Icons.person, color: Colors.grey)
                                        : null,
                                  ),
                                  title: Text(
                                    conf.studentName,
                                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                  ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(statusText, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 5),
                                    Icon(icon, color: color),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Text("error".tr()),
                      ),
                    ],
                  ],
                ),
              ),
            );
        },
        loading: () => LoadingWidget(),
        error: (e, stack) {
          if (e is UnauthorizedException) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomErrorWidget(
            providerToInvalidate: eventDetailsProvider,
          );
        },
      )
    );
  }
}
