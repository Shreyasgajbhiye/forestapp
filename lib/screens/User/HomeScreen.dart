import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vector_math/vector_math.dart' as VMath;
import 'package:intl/intl.dart';

import '../../common/models/TigerModel.dart';
import '../loginScreen.dart';
import 'ForestDataScreen.dart';
import 'ForestDetail.dart';
import 'package:forestapp/utils/util.dart';

class ProfileData {
  final String title;
  final String description;
  final String imageUrl;
  final String userName;
  final String userEmail;
  final Timestamp? datetime;

  ProfileData({
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.userName,
    required this.userEmail,
    this.datetime,
  });
}

class HomeScreen extends StatefulWidget {
  final Function(int) changeScreen;
  final Function(bool) showNavBar;

  const HomeScreen({super.key, required this.changeScreen, required this.showNavBar});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  //final LatLng _circleCenter = LatLng(20.9189175, 77.7736374);


  ValueNotifier<int> dialogTrigger = ValueNotifier(0);
  Future<void>? _future;
  LatLng? _currentLocation;

  late String _userEmail;
  late double _longitude;
  late double _latitude;
  late double _circleRadius; // radius in meters, 50000=km
  //final LatLng _circleCenter = LatLng(20.9189175, 77.7736374);
  late List<TigerModel> _profileDataList = [];

  int _userProfileDataCount = 0;

  int? _count;
  //String? longitude;
  //String? latitude;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    getTotalDocumentsCount().then((value) {
      setState(() {
        _count = value;
      });
    });
    getTotalDocumentsCountUser().then((value) {});

    _future = init();
  }

  Future<void> init() async {
    if( Util.hasUserLocation == false ) {
      await _getCurrentLocation();

      isPointInsideCircle( _currentLocation! );
      Util.hasUserLocation = true;
      bool result = isPointInsideCircle( _currentLocation! );
      print(result);
      dialogTrigger.value = 1;
    }

    debugPrint("show nav bar ");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.showNavBar(true);
    });
  }


  Future<void> fetchUserEmail() async {
    print("userData fetching");
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    final double longitude = double.parse( prefs.getString('longitude')! );
    final double latitude = double.parse( prefs.getString('latitude')! );
    final double radius = double.parse( prefs.getString('radius')! );
    print(latitude);
    print(longitude);
    print(radius);
    setState(() {
      _userEmail = userEmail ?? '';
      _latitude = latitude;
      _longitude = longitude;
      _circleRadius = radius;
    });

    fetchUserProfileData();
  }

  Future<void> fetchUserProfileData() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('forestdata')
        .where('user_email', isEqualTo: _userEmail)
        // .orderBy('createdAt', descending: true)
        .limit(5)
        .get();
    final profileDataList = userSnapshot.docs
        .map((doc) => TigerModel(
      id: doc['id'],
      range: doc['range']['name'],
      round: doc['round']['name'],
      beat: doc['beat']['name'],
      imageUrl: doc['imageUrl'],
      title: doc['title'],
      description: doc['description'],
      userName: doc['user_name'],
      userEmail: doc['user_email'],
      datetime: doc['createdAt'] as Timestamp?,
      location: doc['location'] as GeoPoint,
      noOfCubs: doc['number_of_cubs'],
      noOfTigers: doc['number_of_tiger'],
      remark: doc['remark'],
      userContact: doc['user_contact'],
      userImage: doc['user_imageUrl'],
      //longitude: doc.data().containsKey('longitude')?  doc['longitude'] : null,
      //latitude: doc.data().containsKey('latitude')? doc['latitude'] : null,
    ))
        .toList();
    setState(() {
      _profileDataList = profileDataList;
      _userProfileDataCount = userSnapshot.size;
    });
    print(_profileDataList.toString());
  }



  Future<int> getTotalDocumentsCount() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('forestdata')
        // .where('user_email', isEqualTo: _userEmail)
        // .orderBy('createdAt', descending: true)
        .get();
    return snapshot.size;
  }

  Future<int> getTotalDocumentsCountUser() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.size;
  }

  // late final int numberOfTigers;
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  Future<bool> _onWillPop(BuildContext context) async {
    bool? exitResult = await showDialog(
      context: context,
      builder: (context) => _buildExitDialog(context),
    );
    return exitResult ?? false;
  }

  AlertDialog _buildExitDialog(BuildContext context) {
    return AlertDialog(
      title: const Text('Please confirm'),
      content: const Text('Do you want to exit the app?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('No'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('Yes'),
        ),
      ],
    );
  }

  AlertDialog _isInside(BuildContext context) {
    return AlertDialog(
      title: const Text('You are outside the previliged area..'),
      content: const Text('Do you want to exit the app?'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            SharedPreferences prefs =
                await SharedPreferences.getInstance();
            prefs.remove('userEmail');
            Util.hasUserLocation = false;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const LoginScreen()),
                  (route) => false,
            );
          },
          child: Text('Logout',style: TextStyle(
            color: Colors.red,
          )),
        ),
        TextButton(
          onPressed: () {
            exit(0);
          },
          child: Text('Yes'),
        ),

      ],
    );
  }

  AlertDialog _isEmpty(BuildContext context) {
    return AlertDialog(
      title: const Text('Data not found'),
      content: const Text('Do you want to exit the app?'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            SharedPreferences prefs =
            await SharedPreferences.getInstance();
            prefs.remove('userEmail');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => const LoginScreen()),
                  (route) => false,
            );
          },
          child: Text('Logout',style: TextStyle(
            color: Colors.red,
          )),
        ),
        TextButton(
          onPressed: () => exit(0),
          child: Text('Yes'),
        ),

      ],
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Location Services Disabled'),
          content: Text('Please enable location services to continue.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    // Request location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Location Permissions Denied'),
            content: Text('Please grant location permissions to continue.'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Location Permissions Denied'),
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    // Get the current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    return;
  }


  bool isPointInsideCircle(LatLng point) {
    if ( _longitude==null || _latitude==null ) {
        return false;
    }

    double distance = Geolocator.distanceBetween(
      point.latitude,
      point.longitude,
      _latitude,
      _longitude,
    );

    return (distance <= _circleRadius);
  }



  @override
  Widget build(BuildContext context) {
    //widget.showNavBar();
    return FutureBuilder(
      future: _future,
      builder: (context,snapshot){
        if( snapshot.connectionState == ConnectionState.waiting ) {
          return Center(
            child:Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Finding your current location...",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  width: 10,
                ),
                CircularProgressIndicator()
              ],
            ),
          );
        }
        else{
          if ( _currentLocation != null && isPointInsideCircle( _currentLocation! ) == false ) {
            return WillPopScope(
              onWillPop: ()=> _onWillPop(context),
              child: Container(
                  child: ValueListenableBuilder(
                      valueListenable: dialogTrigger,
                      builder: (ctx, value, child) {

                        Future.delayed(const Duration(seconds: 0), () {
                          showDialog(
                              barrierDismissible: false,
                              context: ctx,
                              builder: (ctx) {
                                return _isInside(context);
                              });
                        });

                        return const SizedBox();
                      })
              ),
            );
          }
          else if ( snapshot.hasError ) {
            debugPrint( snapshot.error.toString() );
            debugPrint( snapshot.stackTrace.toString() );

            return Center(
              child: Text("Some error occured!"),
            );

          }
          else if (_profileDataList.isEmpty) {
            return WillPopScope(
                child: Scaffold(
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
                    title: const Text('Pench MH'),
                    actions: [
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Logout'),
                                  content:
                                  const Text('Are you sure you want to log out?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Util.hasUserLocation = false;
                                        print("test");

                                        SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                        prefs.remove('userEmail');

                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => const LoginScreen()),
                                              (route) => false,
                                        );
                                      },
                                      child: const Text('Logout',style: TextStyle(color: Colors.red,),),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                // perform logout
                              }
                            },
                          ),
                          // const Text("Logout"),
                        ],
                      ),
                    ],
                  ),
                  body: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "No Data Found.....",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        CircularProgressIndicator()
                      ],
                    ),
                  ),
                ), onWillPop: () => _onWillPop(context));
          }
          else {return WillPopScope(child: Scaffold(
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
                  ),
              ),
              title: const Text('Pench MH'),
              actions: [
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Logout'),
                            content: const Text('Are you sure you want to log out?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Util.hasUserLocation = false;
                                  print("test");

                                  SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                                  prefs.remove('userEmail');
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const LoginScreen()),
                                        (route) => false,
                                  );
                                },
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          // perform logout
                        }
                      },
                    ),
                    // const Text("Logout"),
                  ],
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16.0),
                    InkWell(
                      onTap: () {
                        {
                          widget.changeScreen(2);
                        }
                        // Navigator.of(context).pushAndRemoveUntil(
                        //     MaterialPageRoute(
                        //         builder: (context) => const ForestDataScreen(changeIndex: ,)),
                        //         (route) => false);
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              const Text(
                                'Total Tigers Entries',
                                style: TextStyle(fontSize: 20.0),
                              ),
                              const Icon(
                                Icons.trending_up,
                                size: 50.0,
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                '$_userProfileDataCount',
                                style: TextStyle(fontSize: 24.0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Recent Entries",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 16.0,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade500),
                          ),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Tiger Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'User Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Date & Time',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'View',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                          rows: _profileDataList.map((profileData) {
                            return DataRow(
                              cells: [
                                DataCell(Text(profileData.title)),
                                DataCell(Text(profileData.userName)),
                                DataCell(Text(DateFormat('dd/MM/yyyy hh:mm')
                                    .format(profileData.datetime!.toDate()))),
                                DataCell(IconButton(
                                  onPressed: () {
                                    // {
                                    //   widget.changeScreen(2);
                                    // }
                                    {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) => ForestDetail(
                                                changeIndex: (int) {
                                                  widget.changeScreen( 2 );
                                                },
                                                changeData:  (TigerModel newData) {
                                                  setState(() {
                                                    _profileDataList.removeWhere((element) => element.id == newData.id );
                                                    _profileDataList.insert(0, newData);
                                                  });
                                                },
                                                deleteData: (TigerModel data) {
                                                  setState(() {

                                                    _profileDataList.removeWhere((element) => element.id == data.id);
                                                  });
                                                },
                                                forestData: profileData,
                                              )
                                          )
                                      );
                                    }
                                  },
                                  icon: Icon(Icons.visibility),
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ), onWillPop: () => _onWillPop(context));}
        }
      },
    );


  }
}
