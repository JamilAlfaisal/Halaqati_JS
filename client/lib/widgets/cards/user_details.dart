import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class UserDetails extends StatelessWidget {
  final String email;
  final String phone;
  final String? dob;
  const UserDetails({
    super.key,
    required this.phone,
    required this.email,
    this.dob
  });

  @override
  Widget build(BuildContext context) {

    String getDOB(String ?date){

      if(date == null){
        return "teacher_profile.no_DOB".tr();
      }else{
        return date.split('T')[0];
      }
    }


    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5,spreadRadius: 1),
        ],
      ),
      child: Column(
        children: [
          Row(
            spacing: 5,
            children: [
              Icon(
                Icons.alternate_email_outlined,
                size: 20,
              ),
              Text(
                email,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: 5,),
          Row(
            spacing: 5,
            children: [
              Icon(Icons.phone_android_rounded, size: 20,),
              Text(
                phone,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          SizedBox(height: 5,),
          Row(
            spacing: 5,
            children: [
              Icon(Icons.date_range_sharp, size: 20,),
              Text(
                getDOB(dob),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
