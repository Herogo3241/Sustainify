import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:fl_chart/fl_chart.dart';

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
  List<int> monthlyPoints = [];
  List<String> monthLabels = [];
  late List<UserPoints> _userPoints = [];

  Future<void> _fetchMonthlyTrackerData() async {
    // Get the current year and month
    String currentYearMonth = DateTime.now().toString().substring(0, 7);
    List<String> latestMonths = []; // Store latest 5 months
    for (int i = 0; i < 5; i++) {
      latestMonths.add(currentYearMonth);
      // Update current year and month to get previous months
      currentYearMonth = _getPreviousMonth(currentYearMonth);
    }

    for (String month in latestMonths.reversed) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('monthly_tracker')
          .doc(month)
          .get();


      if (snapshot.exists) {
        int totalPoints = snapshot['totalPoints'];
        monthlyPoints.add(totalPoints);
        monthLabels.add(month);
      } else {
        monthlyPoints.add(0);
        monthLabels.add(month);
      }
    }

    setState(() {});
  }

  String _getPreviousMonth(String yearMonth) {
    // Convert string to DateTime
    DateTime dateTime = DateTime.parse('$yearMonth-01');
    // Subtract one month from DateTime
    DateTime previousMonth =
        DateTime(dateTime.year, dateTime.month - 1, dateTime.day);
    // Format DateTime to 'yyyy-MM' string
    return '${previousMonth.year}-${previousMonth.month.toString().padLeft(2, '0')}';
  }

  Future<void> _fetchUserPoints() async {
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('monthly_tracker').get();

    List<UserPoints> userPoints = [];

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      String userId = doc['userId'];

      // Query the subcollection 'users' for the user's total points
      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await FirebaseFirestore.instance
              .collection('monthly_tracker')
              .doc(doc.id) // Document ID of monthly tracker (same as the month)
              .collection('users')
              .doc(userId)
              .get();

      if (userSnapshot.exists) {
        userId = userSnapshot['userId'];
        int totalPoints = userSnapshot['totalPoints'];
        userPoints.add(UserPoints(userId: userId, totalPoints: totalPoints));
      }
    }

    // Sort the userPoints list based on total points
    userPoints.sort((a, b) => b.totalPoints.compareTo(a.totalPoints));

    setState(() {
      _userPoints = userPoints;
    });
  }

  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    int totalPoints = tracker.Recycled +
        tracker.CreatedPosts * 5 +
        tracker.HostedEvents * 20 +
        tracker.ParticipatedEvents * 10;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Sustainability Tracker'),
        ),
        body: Center(
          child: CircularProgressIndicator(), // Circular loader
        ),
      );
    }

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
          SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: monthlyPoints[0].toDouble(),
                        color: Colors.green,
                        width: 20,
                      ),
                      BarChartRodData(
                        toY: monthlyPoints[1].toDouble(),
                        color: Colors.green,
                        width: 20,
                      ),
                      BarChartRodData(
                        toY: monthlyPoints[2].toDouble(),
                        color: Colors.green,
                        width: 20,
                      ),
                      BarChartRodData(
                        toY: monthlyPoints[3].toDouble(),
                        color: Colors.green,
                        width: 20,
                      ),
                      BarChartRodData(
                        toY: monthlyPoints[4].toDouble(),
                        color: Colors.green,
                        width: 20,
                      ),
                    ],
                  )
                ],
                titlesData: FlTitlesData(
                  show: false,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // Display top 5 users
              itemBuilder: (context, index) {
                // Fake user data
                final List<Map<String, dynamic>> fakeUserData = [
                  {"username": "John", "totalPoints": 800},
                  {"username": "Alice", "totalPoints": 750},
                  {"username": "Bob", "totalPoints": 700},
                  {"username": "Emma", "totalPoints": 650},
                  {"username": "Michael", "totalPoints": 600},
                ];

                // Ensure index does not exceed fake user data length
                if (index < fakeUserData.length) {
                  final userData = fakeUserData[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 8.0),
                    child: Card(
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          'User ID: ${userData["username"]}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle:
                            Text('Total Points: ${userData["totalPoints"]}'),
                        trailing: index == 0 ? Icon(Icons.star, color: Color.fromARGB(255, 0, 76, 24)) : null,
                      ),
                    ),
                  );
                } else {
                  return SizedBox(); // Return an empty container if index is out of range
                }
              },
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
    // Call methods to fetch data
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      _fetchRecycledCount();
      _fetchHostedEventsCount();
      _fetchPostsCreatedCount();
      _fetchParticipatedEventsCount();
      await _updateMonthlyTrackerData();
      await _fetchMonthlyTrackerData();
      await _fetchUserPoints();
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error appropriately
    } finally {
      setState(() {
        _isLoading = false; // Mark loading as completed
      });
    }
  }

  // Method to fetch hosted events count

  void _fetchRecycledCount() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
            .instance
            .collection('recycle_tracker')
            .where('userId', isEqualTo: user.uid)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Assuming there's only one document per user
          var documentData = snapshot.docs.first.data();
          // Access the recycleAmount field and assign it to tracker.Recycled
          tracker.Recycled = documentData['recycleAmount'].ceil();
          // Update other parts of your UI if necessary
          _updateMonthlyTrackerData();
        } else {
          // Handle the case where the user's document is not found
          print('No recycle data found for the user.');
        }
      } catch (e) {
        print('Error fetching recycle count: $e');
      }
    } else {
      print('User is not authenticated.');
    }
  }

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

  void _fetchParticipatedEventsCount() async {
    User? user = FirebaseAuth.instance.currentUser;
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('events')
        .where('createdBy', isNotEqualTo: user!.uid)
        .get();

    setState(() {
      tracker.ParticipatedEvents = snapshot.size;
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
    String currentYearMonth = DateTime.now().toString().substring(0, 7);
    // Get current year and month
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

      // Create a subcollection 'users' and store the total points for the user
      await monthlyTrackerRef.collection('users').doc(user.uid).set({
        'userId': user.uid,
        'totalPoints': tracker.Recycled +
            tracker.CreatedPosts * 5 +
            tracker.HostedEvents * 20 +
            tracker.ParticipatedEvents * 10,
      });
    }
  }
}

class UserPoints {
  final String userId;
  final int totalPoints;

  UserPoints({required this.userId, required this.totalPoints});
}
