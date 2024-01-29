import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class Event {
  final String title;
  final String description;
  final DateTime date;
  final String location;

  Event({
    required this.title,
    required this.description,
    required this.date,
    required this.location,
  });
}

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
            ),
            SizedBox(height: 20),
            DateTimeField(
              format: DateFormat("yyyy-MM-dd"),
              onChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
              decoration: InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                  context: context,
                  initialDate: currentValue ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
              },
            ),
            SizedBox(height: 20),
            DateTimeField(
              format: DateFormat("HH:mm"),
              onChanged: (time) {
                setState(() {
                  _selectedTime = TimeOfDay.fromDateTime(time!);
                });
              },
              decoration: InputDecoration(
                labelText: 'Time',
                border: OutlineInputBorder(),
              ),
              onShowPicker: (context, currentValue) async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(
                    currentValue ?? DateTime.now(),
                  ),
                );
                return DateTimeField.convert(time);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_selectedDate != null && _selectedTime != null) {
                  // Combine selected date and time
                  DateTime selectedDateTime = DateTime(
                    _selectedDate!.year,
                    _selectedDate!.month,
                    _selectedDate!.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  );

                  // Create the event
                  Event newEvent = Event(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    date: selectedDateTime,
                    location: _locationController.text,
                  );

                  // Navigate back to the events list and pass the new event
                  Navigator.pop(context, newEvent);
                } else {
                  // Inform the user to select date and time
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select date and time.'),
                    ),
                  );
                }
              },
              child: Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}


