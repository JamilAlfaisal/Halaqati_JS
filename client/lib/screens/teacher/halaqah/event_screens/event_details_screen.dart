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
import 'package:halqati/widgets/loading_widget.dart';
import 'package:halqati/widgets/textfields/custome_date_picker.dart';
import 'package:halqati/widgets/textfields/text_area.dart';
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



  @override
  Widget build(BuildContext context) {
    final asyncEvent = ref.watch(eventDetailsProvider);
    final String halaqahName = ref.watch(selectedClassNameProvider)??"name".tr();

    void updateEvent() async {

      await ref.read(eventDetailsProvider.notifier).updateEventDetails(
        title: title.text,
        description: des.text,
        dueDate: date.text,
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

    bool ability = true;

    return Scaffold(
      appBar: AppbarWithButton(
          text: halaqahName,
          addBackButton: true
      ),
      body: asyncEvent.when(
        data: (event){
          if (!_initialized && event != null) {
            _initialized = true;
            print(event.title);
            des.text = event.description;
            title.text = event.title;
            date.text = HelperMethods.formatDate(event.dueDate);
          }


          return RefreshIndicator(
            onRefresh: () async {
              _initialized = false;
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
                  ElevatedDark(
                    onPressed: () {
                      updateEvent();
                    },
                    text: "update".tr(),
                    ability: ability,
                  ),
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
            providerToInvalidate: eventProvider,
          );
        },
      )
    );
  }
}
