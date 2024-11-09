import 'package:flutter/material.dart';

Future<DateTime?> showCustomCalendar({
  required BuildContext context,
}) async {
  return await showDialog<DateTime>(
    context: context,
    builder: (_) => const CustomCalendar(),
  );
}

class CustomCalendar extends StatefulWidget {
  const CustomCalendar({super.key});

  @override
  CustomCalendarState createState() => CustomCalendarState();
}

class CustomCalendarState extends State<CustomCalendar> {
  int selectedDay = 16;
  int selectedMonth = 5;
  int selectedYear = 2018;

  final days = List.generate(31, (index) => index + 1);
  final months = [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];
  final years = List.generate(100, (index) => 1986 + index);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), color: Colors.white
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const DefaultTextStyle(style: TextStyle(fontSize: 16, color: Colors.black), child: Text("Date selector")),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDatePicker<int>(
                  items: days,
                  selectedItem: selectedDay,
                  onSelectedItemChanged: (value) => setState(() => selectedDay = value),
                ),
                const SizedBox(width: 16),
                _buildDatePicker<String>(
                  items: months,
                  selectedItem: months[selectedMonth],
                  onSelectedItemChanged: (value) => setState(() => selectedMonth = months.indexOf(value)),
                ),
                const SizedBox(width: 16),
                _buildDatePicker<int>(
                  items: years,
                  selectedItem: selectedYear,
                  onSelectedItemChanged: (value) => setState(() => selectedYear = value),
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
                  onPressed: () => Navigator.pop(context),
                  child: const DefaultTextStyle(style: TextStyle(fontSize: 14, color: Colors.black), child: Text("Cancel")),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.yellow,
                  ),
                  onPressed: () {
                    DateTime selectedDate = DateTime(selectedYear, selectedMonth + 1, selectedDay);
                    Navigator.pop(context, selectedDate);
                  },
                  child: const DefaultTextStyle(style: TextStyle(fontSize: 14, color: Colors.black), child: Text("Set date")),
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
    return SizedBox(
      height: 150,
      width: MediaQuery.of(context).size.width * .2,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 60,
        perspective: 0.005,
        diameterRatio: 10,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) => onSelectedItemChanged(items[index]),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final item = items[index];
            final isSelected = item == selectedItem;
            return Center(
              child: DefaultTextStyle(
                style: TextStyle(
                  fontSize: isSelected ? 20 : 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
    );
  }
}
