import 'package:flutter/material.dart';

class DatePickerScreen extends StatefulWidget {
  const DatePickerScreen({super.key});

  @override
  DatePickerScreenState createState() => DatePickerScreenState();
}

class DatePickerScreenState extends State<DatePickerScreen> {
  final TextEditingController _dateController = TextEditingController();

  void _showFullScreenDatePicker() async {
    DateTime? selectedDate = await showDialog<DateTime>(
      context: context,
      builder: (_) => const FullScreenDatePicker(),
    );

    if (selectedDate != null) {
      int age = _calculateAge(selectedDate);
      _dateController.text =
          "${selectedDate.day} ${_getMonthName(selectedDate.month)} ${selectedDate.year} (Age: $age years)";
    }
  }

  int _calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }
  String _getMonthName(int month) {
    const monthNames = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return monthNames[month - 1];
  }

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
              onTap: _showFullScreenDatePicker,
            ),
          ],
        ),
      ),
    );
  }
}

class FullScreenDatePicker extends StatefulWidget {
  const FullScreenDatePicker({super.key});

  @override
  FullScreenDatePickerState createState() => FullScreenDatePickerState();
}

class FullScreenDatePickerState extends State<FullScreenDatePicker> {
  int selectedDay = 16;
  int selectedMonth = 5; // June (index 5)
  int selectedYear = 2018;

  final days = List.generate(31, (index) => index + 1);
  final months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];
  final years = List.generate(100, (index) => 1986 + index);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), color: Colors.white),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const DefaultTextStyle(
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                  child: Text(
                    "Date selector",
                  ),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close))
              ],
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDatePicker<int>(
                  items: days,
                  selectedItem: selectedDay,
                  onSelectedItemChanged: (value) =>
                      setState(() => selectedDay = value),
                ),
                const SizedBox(width: 16),
                _buildDatePicker<String>(
                  items: months,
                  selectedItem: months[selectedMonth],
                  onSelectedItemChanged: (value) =>
                      setState(() => selectedMonth = months.indexOf(value)),
                ),
                const SizedBox(width: 16),
                _buildDatePicker<int>(
                  items: years,
                  selectedItem: selectedYear,
                  onSelectedItemChanged: (value) =>
                      setState(() => selectedYear = value),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const DefaultTextStyle(
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                        child: Text("Cancel"))),
                const SizedBox(
                  width: 10,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.yellow,
                  ),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      DateTime(selectedYear, selectedMonth + 1, selectedDay),
                    );
                  },
                  child: const DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    child: Text("Set date"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker<T>({
    required List<T> items,
    required T selectedItem,
    required ValueChanged<T> onSelectedItemChanged,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Lines above and below the selected item
        const Positioned(
          top: 40,
          left: 0,
          right: 0,
          child: Divider(color: Colors.grey, thickness: 1),
        ),
        const Positioned(
          bottom: 40,
          left: 0,
          right: 0,
          child: Divider(color: Colors.grey, thickness: 1),
        ),
        // The ListWheelScrollView itself
        SizedBox(
          height: 150,
          width: MediaQuery.of(context).size.width * .2,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 60,
            perspective: 0.005,
            diameterRatio: 10,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) =>
                onSelectedItemChanged(items[index]),
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                final item = items[index];
                final isSelected = item == selectedItem;
                return Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontSize: isSelected ? 20 : 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.black : Colors.grey,
                    ),
                    child: Text(
                      "$item",
                    ),
                  ),
                );
              },
              childCount: items.length,
            ),
          ),
        ),
      ],
    );
  }
}