import 'package:components_test/widgets/custom_calendar.dart';
import 'package:flutter/material.dart';

class DatePickerScreen extends StatefulWidget {
  const DatePickerScreen({super.key});

  @override
  DatePickerScreenState createState() => DatePickerScreenState();
}

class DatePickerScreenState extends State<DatePickerScreen> {
  final TextEditingController _dateController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Date Picker"),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _dateController,
              decoration: const InputDecoration(
                labelText: "Selected Date",
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async{
                DateTime? selectedDate =  await showCustomCalendar(context: context);
                if(selectedDate != null){
                  _dateController.text = "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}