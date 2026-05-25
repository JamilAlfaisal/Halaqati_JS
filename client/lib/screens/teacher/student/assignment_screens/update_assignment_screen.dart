import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halqati/core/exceptions/api_exceptions.dart';
import 'package:halqati/core/utils/auth_utils.dart';
import 'package:halqati/models/assignment.dart';
import 'package:halqati/models/student.dart';
import 'package:halqati/provider/selected_class_name_provider.dart';
import 'package:halqati/provider/selected_student_name.dart';
import 'package:halqati/provider/teacher_providers/assignment_provider.dart';
import 'package:halqati/provider/teacher_providers/students_provider.dart';
import 'package:halqati/provider/student_providers/selected_assignment_notifier.dart';
import 'package:halqati/provider/services_providers/assignment_api_provider.dart';
import 'package:halqati/provider/token_notifier.dart';
import 'package:halqati/utils/helper_methods.dart';
import 'package:halqati/widgets/appbar/appbar_with_button.dart';
import 'package:halqati/widgets/custom_lable.dart';
import 'package:halqati/widgets/lists/StudentAssignmentList.dart';
import 'package:halqati/widgets/loading_widget.dart';
import 'package:halqati/widgets/textfields/text_field_normal.dart';
import 'package:halqati/widgets/textfields/text_area.dart';
import 'package:halqati/widgets/buttons/elevated_dark.dart';
import 'package:easy_localization/easy_localization.dart';

class UpdateAssignmentScreen extends ConsumerStatefulWidget {
  final bool? generalAssignment;
  const UpdateAssignmentScreen({super.key, this.generalAssignment});

  @override
  ConsumerState<UpdateAssignmentScreen> createState() => _UpdateAssignmentScreenState();
}

class _UpdateAssignmentScreenState extends ConsumerState<UpdateAssignmentScreen> {
  final TextEditingController title = TextEditingController();
  final TextEditingController des = TextEditingController();
  final TextEditingController _pageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  String? _errorMessage;
  bool ability = true;
  String? selectedValue = 'Memorization';
  DateTime? selectedDate;
  List<String> pageNumbers = [];
  List<AssignedStudents> students = []; // student we got from server for this assignment
  List<Map> allStudentsInformation = []; // ids that we want to sent to server (updated ones)
  List<int> studentsIds = [];
  // studentsIds contains objects {isSelected, score, weight, name}
  bool isFirstBuild = true;

  @override
  void initState() {
    super.initState();
    _fetchFreshData();
  }

  @override
  void dispose() {
    title.dispose();
    des.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchFreshData() async {
    setState(() {
      allStudentsInformation = [];
      studentsIds = [];
      isFirstBuild = true;
      _isLoading = true;
      _errorMessage = null;
    });


    final selectedId = ref.read(selectedAssignmentProvider).toString();
    final token = ref.read(tokenProvider).value;
    if (token == null) {
      setState(() {
        _errorMessage = "auth_error".tr();
        _isLoading = false;
      });
      return;
    }

    try {
      final assignment = await ref.read(assignmentApiProvider).getAssignmentDetails(token, selectedId);
      if (assignment != null && mounted) {
        setState(() {
          title.text = assignment.title ?? "";
          des.text = assignment.description ?? "";
          selectedDate = assignment.dueDate;
          selectedValue = assignment.type;
          pageNumbers = List.from(assignment.pages ?? []);
          students =  List.from(assignment.students ?? []);
          _isLoading = false;
        });
      }

    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String get dateText {
    if (selectedDate == null) return "student_bottom_appbar.add_halaqah_screen.date_hint".tr();
    return "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  void _addPage(String value) {
    final int? page = int.tryParse(value.trim());
    if (page != null && !pageNumbers.contains(page.toString())) {
      setState(() {
        pageNumbers.add(page.toString());
        _pageController.clear();
      });
    } else {
      _pageController.clear();
    }
  }

  Future<void> _handleUpdateAssignment() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('select_date'.tr())));
      return;
    }

    setState(() => ability = false);
    if (!_formKey.currentState!.validate()) {
      setState(() => ability = true);
      return;
    }

    final studentId = ref.read(selectedStudentIdProvider);

    try {
      await ref.read(assignmentProvider.notifier).updateAssignmentDetails(
        title: title.text,
        description: des.text,
        pages: pageNumbers.map((page) => int.parse(page)).toList(),
        studentsIds: studentsIds,
        type: selectedValue ?? 'Memorization',
        dueDate: HelperMethods.formatDate(selectedDate),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('saved_success'.tr())));
        Navigator.pop(context);
      }
    } catch (e) {
      if (e is UnauthorizedException) await AuthHelper.handleLogout(ref);
    } finally {
      if (mounted) setState(() => ability = true);
    }
  }

  void setArray (List<Student> allStudents){
    // {isSelected, score, weight, name} studentsIds
    // students AssignedStudents
    setState(() {
      late bool isSelected;
      late double score;
      late String description;
      late String id;
      late String studentId;
      late int weight;
      for(int i = 0; i < allStudents.length; i++){
        isSelected = false;
        weight = 0;
        score = 0.0;
        description = "";
        id = "";
        studentId = "";
        for(int j = 0; j < students.length; j++){
          if (allStudents[i].id == students[j].student.id){
            isSelected = true;
            score = students[j].grade?.score??0.0;
            weight = students[j].grade?.weight??0;
            description = students[j].grade?.description??"";
            id = students[j].grade?.id??"";
            studentId = students[j].student.id;
            break;
          }
        }
        if (isSelected){
          studentsIds.add(int.parse(allStudents[i].id));
          allStudentsInformation.add({
            "isSelected":isSelected,
            "score": score,
            "weight":weight,
            "description":description,
            "id":id,
            "name":allStudents[i].name,
            "studentId":studentId,
          });
        }else{
          allStudentsInformation.add({
            "isSelected":false,
            "score": 0.0,
            "weight":0,
            "description":"",
            "id":"0",
            "name":allStudents[i].name,
            "studentId":""
          });
        }
      }
      isFirstBuild = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String halaqahName = ref.watch(selectedClassNameProvider) ?? "name".tr();
    final String studentName = ref.watch(selectedStudentNameProvider) ?? "name".tr();
    final List<Student> allStudents = ref.watch(studentsProvider).value??[];
    // all students that we got from the server
    if (isFirstBuild && !_isLoading)
      setArray(allStudents); // this method is for making a list combined of students in class and
    // students that the assignment were sent to them
    if (_isLoading) {
      return Scaffold(
        appBar: AppbarWithButton(text: halaqahName, addBackButton: true),
        body: LoadingWidget(),
      );
    }

    if (_errorMessage != null) {

      return Scaffold(
        appBar: AppbarWithButton(text: halaqahName, addBackButton: true),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchFreshData,
                icon: const Icon(Icons.refresh),
                label: Text("retry".tr()),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppbarWithButton(text: halaqahName, addBackButton: true),
      body: RefreshIndicator(
        onRefresh: _fetchFreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.generalAssignment == null)
                  CustomLabel(text: studentName),
                  TextFieldNormal(
                    hintText: "title".tr(),
                    textController: title,
                    title: "title".tr(),
                  ),
                  const SizedBox(height: 10),
                  TextArea(textController: des, title: "des".tr()),
                  const SizedBox(height: 10),

                  Text("pages".tr(), style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,

                    children: pageNumbers.map(
                      (page) => Chip(
                        color: WidgetStateColor.transparent,
                        label: Text(page, style: TextTheme.of(context).bodyLarge,),
                        onDeleted: () {
                          setState(() => pageNumbers.remove(page));
                        },
                        deleteIconColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                    ).toList(),
                  ),
                  TextField(
                    controller: _pageController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "page_num".tr()),
                    onSubmitted: _addPage,
                  ),
                  const SizedBox(height: 20),

                  InkWell(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(dateText, style: Theme.of(context).textTheme.bodyLarge),
                          const Icon(Icons.calendar_month_rounded),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildDropdown(),

                  const SizedBox(height: 30),
                  Text("sent_to".tr(), style: Theme.of(context).textTheme.bodyLarge),
                  Container(
                    height: MediaQuery.of(context).size.height*0.4,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.secondaryContainer, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListView.builder(
                      itemCount: allStudentsInformation.length,
                      itemBuilder: (context, index){
                        return StudentAssignmentTile(
                          isSelected: allStudentsInformation[index]["isSelected"]??false,
                          name: allStudentsInformation[index]["name"]??"name",
                          onToggle: (value){
                            setState(() {
                              // allStudentsInformation
                              // studentsIds
                              if (value == true){
                                studentsIds.add(int.parse(allStudents[index].id));
                                allStudentsInformation[index]['isSelected'] = true;
                              }else{
                                if (allStudentsInformation[index]['weight'] != 0){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('You_unselect_student_already_have_grade'.tr()))
                                  );
                                  return;
                                }
                                studentsIds.remove(int.parse(allStudents[index].id));
                                allStudentsInformation[index]['isSelected'] = false;
                              }
                            });
                          },
                          score: allStudentsInformation[index]["score"]??0.0,
                          weight: allStudentsInformation[index]["weight"]??0,
                          description: allStudentsInformation[index]["description"],
                          id: allStudentsInformation[index]["id"],
                          title: title.text,
                          studentId: allStudentsInformation[index]["studentId"]
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedDark(
                    onPressed: _handleUpdateAssignment,
                    text: "update".tr(),
                    ability: ability,
                  ),

                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    final List<Map<String, String>> items = [
      {'value': 'Revision', 'label': 'revision'.tr()},
      {'value': 'Memorization', 'label': 'memorization'.tr()},
      {'value': 'Reading', 'label': 'reading'.tr()},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          items: items.map((item) => DropdownMenuItem(
            value: item['value'],
            child: Text(item['label']!, style: TextTheme.of(context).bodyLarge,),
          )).toList(),
          onChanged: (val) => setState(() => selectedValue = val),
        ),
      ),
    );
  }
}