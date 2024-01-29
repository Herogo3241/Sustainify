import 'package:flutter/material.dart';
import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Define the Event model
// Add your imports here

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

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addEvent(Event event) async {
    try {
      await _firestore.collection('events').add({
        'title': event.title,
        'description': event.description,
        'date': event.date,
        'location': event.location,
        'createdBy': FirebaseAuth.instance.currentUser!.uid,
      });
    } catch (e) {
      print('Error adding event: $e');
      throw e; // Rethrow the exception to handle it at the caller level
    }
  }

  Stream<List<Event>> fetchAllEvents() {
    return _firestore.collection('events').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Event(
          title: doc['title'],
          description: doc['description'],
          date: doc['date'].toDate(),
          location: doc['location'],
        );
      }).toList();
    });
  }

  Stream<List<Event>> fetchUserEvents() {
    return _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('events')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Event(
          title: doc['title'],
          description: doc['description'],
          date: doc['date'].toDate(),
          location: doc['location'],
        );
      }).toList();
    });
  }
}

class EventPage extends StatefulWidget {
  @override
  _EventsPageState createState() => _EventsPageState();
}

class _EventsPageState extends State<EventPage> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
      ),
      body: StreamBuilder<List<Event>>(
        stream: _firebaseService.fetchAllEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text("No Events Available"),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else {
            List<Event> events = snapshot.data!;
            return ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                return EventListItem(event: events[index]);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newEvent = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateEventPage()),
          );
          if (newEvent != null) {
            try {
              await _firebaseService.addEvent(newEvent);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Event created successfully')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error creating event: $e')),
              );
            }
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class EventListItem extends StatelessWidget {
  final Event event;

  EventListItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle onTap if needed
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                event.title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Date: ${DateFormat('yyyy-MM-dd').format(event.date)}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              // Add more information here if needed
            ],
          ),
        ),
      ),
    );
  }
}

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

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
            ElevatedButton(
              onPressed: () {
                final newEvent = Event(
                  title: _titleController.text,
                  description: _descriptionController.text,
                  location: _locationController.text,
                  date: _selectedDate ?? DateTime.now(),
                );
                Navigator.pop(context, newEvent);
              },
              child: Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}
