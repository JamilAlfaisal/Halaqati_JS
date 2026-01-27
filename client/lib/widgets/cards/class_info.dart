import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halqati/models/halaqa_class.dart';
import 'package:halqati/models/student.dart';

class ClassInfo extends StatelessWidget {
  final HalaqaClass? classInfo;
  const ClassInfo({super.key, required this.classInfo});

  @override
  Widget build(BuildContext context) {
    Map<String, String> enDays = {
      "Monday":"الاثنين",
      "Tuesday":"الثلاثاء",
      "Wednesday":"الأربعاء",
      "Thursday":"الخميس",
      "Friday":"الجمعة",
      "Saturday":"السبت",
      "Sunday":"الأحد"
    };

    final String className = classInfo?.name??"not_defined".tr();
    final int studentCount = classInfo?.studentCount??0;
    final String time = classInfo?.time??"not_defined".tr();
    final String location = classInfo?.roomNumber??"not_defined".tr();
    final List<String> days = classInfo?.days ??[];
    final int capacity = classInfo?.capacity??0;

    late final List<String> localDays;
    late final List<String> startEndTime;

    if(context.locale.languageCode == 'en'){
      localDays = days;
    }else{
      localDays = days.map((day){
        return enDays[day]??day;
      }).toList();
    }

    if(time.contains('-')){
      startEndTime = time.split('-');
    }else{
      startEndTime = ['00:00', '00:00'];
    }

    return classInfo != null
    ?Container(
      width: double.maxFinite,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        border: Border.all(
          color: Theme.of(context).primaryColor,
          width: 2
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Container()
      ),
    ):Center(
      child: Text(
        "dashboard_screen.no_halaqat".tr(),
        style: Theme.of(context).textTheme.bodyLarge,
      )
    );
  }
}

//
// Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Center(
// child: Text(
// className,
// style: Theme.of(context).textTheme.bodyLarge,
// ),
// ),
// SizedBox(height: 20,),
// SizedBox(
// height: 30,
// width: double.maxFinite,
// child: Row(
// crossAxisAlignment: CrossAxisAlignment.center,
// children: [
// Text(
// "${'dashboard_screen.days'.tr()}:",
// style: Theme.of(context).textTheme.bodyLarge
// ),
// Expanded(
// child: ListView.builder(
// scrollDirection: Axis.horizontal,
// itemCount: localDays.length,
// itemBuilder: (context, index){
// return Container(
// alignment: Alignment.center,
// margin: EdgeInsets.only(left: 4),
// padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
// decoration: BoxDecoration(
// // color: Theme.of(context).primaryColor,
// border: Border.all(
// width: 1,
// color: Theme.of(context).primaryColor
// ),
// borderRadius: BorderRadius.all(Radius.circular(16)),
// ),
// child: Text(localDays[index]),
// );
// },
// ),
// ),
// ],
// ),
// ),
// SizedBox(height: 5,),
// SizedBox(
// height: 30,
// width: double.maxFinite,
// child: Row(
// crossAxisAlignment: CrossAxisAlignment.center,
// children: [
// Text(
// "${'dashboard_screen.time'.tr()}:",
// style: Theme.of(context).textTheme.bodyLarge
// ),
// Container(
// alignment: Alignment.center,
// margin: EdgeInsets.only(left: 4),
// padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
// decoration: BoxDecoration(
// // color: Theme.of(context).primaryColor,
// border: Border.all(
// width: 1,
// color: Theme.of(context).primaryColor
// ),
// borderRadius: BorderRadius.all(Radius.circular(16)),
// ),
// child: Text(startEndTime[0]),
// ),
// Icon(Icons.arrow_forward_rounded, size: 25,),
// Container(
// alignment: Alignment.center,
// margin: EdgeInsets.only(left: 4),
// padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
// decoration: BoxDecoration(
// // color: Theme.of(context).primaryColor,
// border: Border.all(
// width: 1,
// color: Theme.of(context).primaryColor
// ),
// borderRadius: BorderRadius.all(Radius.circular(16)),
// ),
// child: Text(startEndTime[1]),
// ),
// ],
// ),
// ),
// SizedBox(height: 5,),
// Row(
// crossAxisAlignment: CrossAxisAlignment.center,
// spacing: 1,
// children: [
// Text(
// "${'dashboard_screen.location'.tr()}:",
// style: Theme.of(context).textTheme.bodyLarge,
// ),
// Expanded(
// child: SingleChildScrollView(
// scrollDirection: Axis.horizontal,
// child: Text(
// location,
// maxLines: 1,
// ),
// ),
// ),
// Icon(Icons.double_arrow_outlined, size: 24,)
// ],
// ),
// SizedBox(height: 5,),
// Text(
// "${'dashboard_screen.student_count'.tr()}: $capacity",
// style: Theme.of(context).textTheme.titleSmall,
// ),
// ],
// ),