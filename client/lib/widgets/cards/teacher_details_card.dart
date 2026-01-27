import 'package:flutter/material.dart';

class TeacherDetailsCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  const TeacherDetailsCard({
    super.key,
    required this.name,
    required this.phone,
    required this.email
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  'assets/images/profile.png',
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              ),
              Expanded(
                flex: 10,
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.start,
                ),
              ),
              Spacer(),
              IconButton(onPressed: (){}, icon: Icon(Icons.email_outlined))
            ],
          ),
          Text(
            "@ $email",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Row(
            children: [
              Icon(
                Icons.phone_android,
                size: 20,
                color: Theme.of(context).colorScheme.secondary,
              ),
              Text(
                phone,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
