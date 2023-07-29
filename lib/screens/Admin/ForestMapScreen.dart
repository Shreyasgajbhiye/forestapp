import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'dart:math' as math;
import '../loginScreen.dart';
import 'ForestDataScreen.dart';

class ProfileData {
  final String title;
  final String description;
  final String imageUrl;
  final String userName;
  final String userEmail;
  final Timestamp? datetime;
  final GeoPoint location;

  ProfileData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.userName,
    required this.userEmail,
    this.datetime,
    required this.location,
  });
}

class ForestMapScreen extends StatefulWidget {
  final Function(int) changeIndex;

  const ForestMapScreen({
    super.key,
    required this.changeIndex, required this.latitude, required this.longitude, required this.userName, required this.tigerName, required this.datetime,
  });

  final double latitude;
  final double longitude;
  final String userName;
  final String tigerName;
  final Timestamp? datetime;

  // ForestMapScreen(
  //     {required this.latitude,
  //     required this.longitude,
  //     required this.userName,
  //     required this.tigerName});

  @override
  _ForestMapScreenState createState() => _ForestMapScreenState();
}

class _ForestMapScreenState extends State<ForestMapScreen> {
  late String _userEmail;
  late List<ProfileData> _profileDataList = [];

  late int _count;
  late int _countUser;

  late MapZoomPanBehavior _zoomPanBehavior;
  late List<MapLatLng> _markers;
  late double _zoomLevel;

  void _onItemTapped(int index) {
    widget.changeIndex( index );
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();

    _markers = [
      MapLatLng(widget.latitude, widget.longitude),
    ];

    fetchUserProfileData();

    _zoomLevel = calculateZoomLevel(_markers);
    _zoomPanBehavior = MapZoomPanBehavior(zoomLevel: _zoomLevel);

    if (_markers.isNotEmpty) {
      // Set zoom level based on the marker location
      _zoomPanBehavior.zoomLevel = 15;
      _zoomPanBehavior.focalLatLng = _markers.first;
    }
  }

  double calculateZoomLevel(List<MapLatLng> markers) {
    if (markers.isEmpty) {
      return 1;
    }

    double maxLat = -90;
    double minLat = 90;
    double maxLon = -180;
    double minLon = 180;

    for (MapLatLng marker in markers) {
      maxLat = math.max(maxLat, marker.latitude);
      minLat = math.min(minLat, marker.latitude);
      maxLon = math.max(maxLon, marker.longitude);
      minLon = math.min(minLon, marker.longitude);
    }

    double deltaLat = maxLat - minLat;
    double deltaLon = maxLon - minLon;
    double zoomLat = math.log(360 / deltaLat) / math.ln2;
    double zoomLon = math.log(360 / deltaLon) / math.ln2;
    double zoom = math.min(zoomLat, zoomLon);

    return zoom;
  }

  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    setState(() {
      _userEmail = userEmail ?? '';
    });
  }

  Future<void> fetchUserProfileData() async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('forestdata').get();
    final profileDataList = userSnapshot.docs
        .map((doc) => ProfileData(
              imageUrl: doc['imageUrl'],
              title: doc['title'],
              description: doc['description'],
              userName: doc['user_name'],
              userEmail: doc['user_email'],
              datetime: doc['createdAt'] as Timestamp?,
              location: doc['location'] as GeoPoint,
            ))
        .toList();
    setState(() {
      _profileDataList = profileDataList;

      // _markers = profileDataList
      //     .map((profileData) => MapLatLng(
      //         profileData.location.latitude, profileData.location.longitude))
      //     .toList();
    });
  }

  Future<bool> _onWillPop(BuildContext context) async {
    Navigator.pop(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (_profileDataList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return WillPopScope(child: Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        flexibleSpace: Container(
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.greenAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            )),
        title: Text(widget.tigerName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.of(context).pushAndRemoveUntil(
            //     MaterialPageRoute(
            //         builder: (context) =>  ForestDataScreen(changeIndex: widget.changeIndex,)),
            //     (route) => false);
            Navigator.pop(context);
          },
        ),
      ),
      body: SfMaps(
        layers: [
          MapTileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            zoomPanBehavior: _zoomPanBehavior,
            markerBuilder: (BuildContext context, int index) {
              return MapMarker(
                latitude: _markers[index].latitude,
                longitude: _markers[index].longitude,
                child: GestureDetector(
                  child: Icon(
                    Icons.location_on,
                    size: 50,
                    color: Colors.red,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(
                          'Tiger: ${widget.tigerName}, Added by: ${widget.userName}, Latitude: ${widget.latitude}, Longitude: ${widget.longitude}, Date: ${widget.datetime!.toDate()}',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w300),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            initialMarkersCount: _markers.length,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Guard',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Forest Data',
            backgroundColor: Colors.black,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Maps',
            backgroundColor: Colors.black,
          ),
        ],
        currentIndex: 2,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    ),
        onWillPop: () => _onWillPop(context));
  }
}
