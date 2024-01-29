import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class SustainabilityTracker {
  int _recycled;
  int _participatedEvents;
  int _hostedEvents;
  int _createdPosts;
  int _totalPoints;

  SustainabilityTracker({
    required int recycled,
    required int participatedEvents,
    required int hostedEvents,
    required int createdPosts,
    required int totalPoints,
  })  : _recycled = recycled,
        _participatedEvents = participatedEvents,
        _hostedEvents = hostedEvents,
        _createdPosts = createdPosts,
        _totalPoints = totalPoints;

  int get Recycled => _recycled;
  int get ParticipatedEvents => _participatedEvents;
  int get HostedEvents => _hostedEvents;
  int get CreatedPosts => _createdPosts;
  int get TotalPoints => _totalPoints;

  set Recycled(int value) {
    _recycled = value;
    _updateTotalPoints();
  }

  set ParticipatedEvents(int value) {
    _participatedEvents = value;
    _updateTotalPoints();
  }

  set HostedEvents(int value) {
    _hostedEvents = value;
    _updateTotalPoints();
  }

  set CreatedPosts(int value) {
    _createdPosts = value;
    _updateTotalPoints();
  }

  void _updateTotalPoints() {
    _totalPoints = _recycled +
        _createdPosts * 5 +
        _hostedEvents * 20 +
        _participatedEvents * 10;
  }
}

class TrackerPage extends StatefulWidget {
  @override
  _TrackerPageState createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  SustainabilityTracker tracker = SustainabilityTracker(
    recycled: 0,
    participatedEvents: 0,
    hostedEvents: 0,
    createdPosts: 0,
    totalPoints: 0,
  );

  @override
  Widget build(BuildContext context) {
    int totalPoints = tracker.Recycled +
        tracker.CreatedPosts * 5 +
        tracker.HostedEvents * 20 +
        tracker.ParticipatedEvents * 10;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sustainability Tracker'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              'Tracker Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _buildTrackerCube(
                  title: 'Recycled',
                  value: tracker.Recycled,
                ),
                _buildTrackerCube(
                  title: 'Event Participated',
                  value: tracker.ParticipatedEvents,
                ),
                _buildTrackerCube(
                    title: 'Event Hosted', value: tracker.HostedEvents),
                _buildTrackerCube(title: 'Posts', value: tracker.CreatedPosts),
              ],
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'Total Points: $totalPoints',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackerCube({required String title, required int value}) {
    final Color borderColor = Color.fromRGBO(22, 242, 22, 0.1);

    return SizedBox(
      width: 200,
      height: 110,
      child: Container(
        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 2.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[200]!],
          ),
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(54, 61, 54, 0.094).withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 5),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Call a method to fetch hosted events count
    _fetchHostedEventsCount();
    _fetchPostsCreatedCount();
    _updateMonthlyTrackerData();
  }

  // Method to fetch hosted events count
  void _fetchHostedEventsCount() async {
    User? user = FirebaseAuth.instance.currentUser;
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('events')
        .where('createdBy', isEqualTo: user!.uid)
        .get();

    setState(() {
      tracker.HostedEvents = snapshot.size;
    });
    _updateMonthlyTrackerData();
  }

  void _fetchPostsCreatedCount() async {
    User? user = FirebaseAuth.instance.currentUser;
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('posts')
        .where('userId', isEqualTo: user!.uid)
        .get();

    setState(() {
      tracker.CreatedPosts = snapshot.size;
    });
    _updateMonthlyTrackerData();
  }

  Future<void> _updateMonthlyTrackerData() async {
    String currentYearMonth =
        DateTime.now().toString().substring(0, 7); // Get current year and month
    DocumentReference monthlyTrackerRef = FirebaseFirestore.instance
        .collection('monthly_tracker')
        .doc(currentYearMonth);

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await monthlyTrackerRef.set({
        'userId': user.uid, // Store the user ID
        'recycled': tracker.Recycled,
        'participated_events': tracker.ParticipatedEvents,
        'hosted_events': tracker.HostedEvents,
        'created_posts': tracker.CreatedPosts,
        'totalPoints': tracker.Recycled +
            tracker.CreatedPosts * 5 +
            tracker.HostedEvents * 20 +
            tracker.ParticipatedEvents * 10,
      });
    }
  }
}
