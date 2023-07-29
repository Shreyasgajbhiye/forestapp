// ignore_for_file: unnecessary_null_comparison

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/common/models/TigerModel.dart';
import 'package:forestapp/screens/Admin/ForestDetail.dart';
import 'package:forestapp/screens/Admin/homeAdmin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:excel/excel.dart';

import 'BottomNavigationProvider.dart';
import 'package:open_filex/open_filex.dart';

class ForestDataScreen extends StatefulWidget {

  final Function(int) changeIndex;

  const ForestDataScreen({
    super.key,
    required this.changeIndex,
  });

  //const ForestDataScreen({Key? key}) : super(key: key);

  @override
  State<ForestDataScreen> createState() => _ForestDataScreenState();
}

class _ForestDataScreenState extends State<ForestDataScreen> {

  // void _onItemTapped(int index) {
  //   widget.changeIndex( index );
  //   Navigator.of(context).pop();
  // }

  late final WebViewController controller;

  Future<bool> _onWillPop(BuildContext context) async {
    // bool? exitResult = await showDialog(
    //   context: context,
    //   builder: (context) => _buildExitDialog(context),
    // );
    // return exitResult ?? false;
    widget.changeIndex( 0 );
    return false;
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

  late String _userEmail;
  late List<TigerModel> _profileDataList = [];
  late List<TigerModel> _searchResult = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=45.523064,-122.676483'),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  Future<void> fetchUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('userEmail');
    setState(() {
      _userEmail = userEmail ?? '';
    });
    fetchUserProfileData();
  }

  Future<void> fetchUserProfileData() async {
    final userSnapshot =
        await FirebaseFirestore.instance.collection('forestdata').get();


    final profileDataList = userSnapshot.docs
        .map(
          (doc) => TigerModel(
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
          ),
        )
        .toList();
    setState(() {
      _profileDataList = profileDataList;
      _searchResult = profileDataList;
    });
    
    

    int totalCubs = 0;
    int totalTigers = 0;

    _profileDataList.forEach((profileData) {
      totalCubs += profileData.noOfCubs;
      totalTigers += profileData.noOfTigers;
    });
  }

  // Function to filter the list based on the selected filter
  void _applyFilter(String filterType) {
    DateTime now = DateTime.now();
    DateTime start;
    switch (filterType) {
      case 'Today':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'Yesterday':
        var yesterday = new DateTime.now().subtract(Duration(days: 1));
        start = DateTime(yesterday.year, yesterday.month, yesterday.day - 1);
        break;
      case 'This Week':
        start = DateTime(now.year, now.month, now.day - now.weekday + 1);
        break;
      case 'This Month':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'This Year':
        start = DateTime(now.year, 1, 1);
        break;
      case 'All':
        start = DateTime(now.year, 1, 1);
        break;
      default:
        print('Invalid filter type: $filterType');
        return;
    }

    List<TigerModel> tempList = [];
    _profileDataList.forEach((profileData) {
      if (profileData.datetime != null &&
          profileData.datetime!.toDate().isAfter(start)) {
        tempList.add(profileData);
      }
    });

    setState(() {
      _searchResult = tempList;
    });
  }

// Function to search the list based on the user input
  void _searchList(String searchQuery) {
    List<TigerModel> tempList = [];

    _profileDataList.forEach((profileData) {
      if (profileData.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          profileData.userName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          profileData.userEmail
              .toLowerCase()
              .contains(searchQuery.toLowerCase())) {
        tempList.add(profileData);
      }
    });
    setState(() {
      _searchResult = tempList;
    });
  }

  void filterData(String? selectedTitle, {bool applyFilter = true}) {
    setState(() {
      if (applyFilter) {
        _searchResult = _profileDataList
            .where((data) => data.title == selectedTitle)
            .toList();
      } else {
        _searchResult = _profileDataList;
      }
    });
  }

// Function to handle the search and filter actions
  void _handleSearchFilter(String searchQuery, String filterType) {
    if (searchQuery.isNotEmpty) {
      _searchList(searchQuery);
    } else if (filterType.isNotEmpty) {
      _applyFilter(filterType);
    } else {
      _searchResult = _profileDataList;
    }
  }

  Future<void> exportToExcel() async {
    Directory? directory;
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // add header row
      sheet.appendRow([
        'Title',
        'Range',
        'Round',
        'Beat',
        'Description',
        'Image URL',
        'User Name',
        'User Email',
        'Created At',
        'Latitude',
        'Longitude',
        'Number Of Cubs',
        'Number Of Tiger',
        'Remark',
        'Contact Number',
        'User Profile',
      ]);

// calculate total cubs and tigers
      int totalCubs = 0;
      int totalTigers = 0;
      _searchResult.forEach((data) {
        totalCubs += data.noOfCubs;
        totalTigers += data.noOfTigers;
      });

// add data rows
      _searchResult.forEach((data) {
        sheet.appendRow([
          data.title,
          data.range,
          data.round,
          data.beat,
          data.description,
          data.imageUrl,
          data.userName,
          data.userEmail,
          data.datetime?.toDate().toString(),
          data.location.latitude,
          data.location.longitude,
          data.noOfCubs,
          data.noOfTigers,
          data.remark,
          data.userContact,
          data.userImage,
        ]);
      });

// add row with total cubs and tigers for all data
      sheet.appendRow([
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        'Total Cubs: ${totalCubs}',
        'Total Cubs: ${totalTigers}',
        '',
        '',
        '',
      ]);




      // save the Excel file
      final fileBytes = excel.encode();
      int fileCount = 0;
      String fileName = 'forest_data.xlsx';

      final storagePermission =
      await Permission.manageExternalStorage.request();
      if (storagePermission.isDenied || storagePermission.isRestricted) {
        openAppSettings();
      }
      directory = await getExternalStorageDirectory();
      String newPath = "";
      print(directory);

      List<String> paths = directory!.path.split("/");
      for (int x = 1; x < paths.length; x++) {
        String folder = paths[x];
        if (folder != "Android") {
          newPath += "/" + folder;
        } else {
          break;
        }
      }
      newPath = newPath + "/ForestApp";
      directory = Directory(newPath);

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      var file = File('${directory.path}/$fileName');

      while (await file.exists()) {
        fileCount++;
        fileName = 'forest_data($fileCount).xlsx';
        file = File('${directory.path}/$fileName');
      }

      await file.writeAsBytes(fileBytes!);

      // show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Excel file saved to folder ForestApp',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          duration: const Duration(seconds: 4),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            onPressed: () async {
              //Use the path to launch the directory with the native file explorer
              await OpenFilex.open('${directory?.path}/$fileName');
            },
            label: "Open",
            textColor: Colors.black,
          ),
        ),
      );
    } catch (e) {
      // show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export to Excel failed: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _selectedFilter = 'All';
  DateTime _fromDate = DateTime.now();
  DateTime _toDate = DateTime.now();

  final List<String> _filterOptions = [
    'Today',
    'Yesterday',
    'This Week',
    'This Month',
    'This Year',
    'All',
  ];

  void clearDropdown() {
    // setState(() {
    //   _selectedTitle = null; // or ""
    // });
    filterData(null,
        applyFilter:
            false); // call filterData with null or "" and applyFilter set to false
  }

  // New functions for filtering by number of tigers and cubs:
  void filterByTigers(int? numberOfTigers) {
    setState(() {
      if (numberOfTigers != null) {
        _searchResult = _profileDataList
            .where((profileData) => profileData.noOfTigers == numberOfTigers)
            .toList();
      } else {
        _searchResult = _profileDataList;
      }
    });
  }

  void filterByCubs(int? numberOfCubs) {
    setState(() {
      if (numberOfCubs != null) {
        _searchResult = _profileDataList
            .where((profileData) => profileData.noOfCubs == numberOfCubs)
            .toList();
      } else {
        _searchResult = _profileDataList;
      }
    });
  }

  int? _selectedTigers;
  int? _selectedCubs;

  final TextEditingController tigersController = TextEditingController();
  final TextEditingController cubsController = TextEditingController();
  final dropdownProvider = Provider.of<BottomNavigationModel>;

  final List<String> _selectedOptions = [];
  String? _selectedTitle;
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final dropdownProvider = Provider.of<BottomNavigationModel>(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          title: Text('Filter'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text('Filter options:'),
                // const SizedBox(height: 8.0),
                // Wrap(
                //   spacing: 8.0,
                //   runSpacing: 8.0,
                //   children: [
                //     for (final option in _filterOptions)
                //       ElevatedButton(
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: _selectedOptions.contains(option)
                //               ? Colors.green
                //               : Colors.lightGreen.shade600,
                //         ),
                //         onPressed: () {
                //           setState(() {
                //             if (_selectedOptions.contains(option)) {
                //               _selectedOptions.remove(option);
                //             } else {
                //               _selectedOptions.add(option);
                //             }
                //             _selectedFilter = _selectedOptions.join(',');
                //           });
                //           _handleSearchFilter(_searchController.text,
                //               _selectedFilter.simplifyText());
                //           // Navigator.pop(context);
                //         },
                //         child: Text(option),
                //       ),
                //   ],
                // ),
                // const SizedBox(height: 8.0),

                Text("Filter by Date"),
                Row(
                  children: [
                    ChangeNotifierProvider(
                      create: (context) => BottomNavigationModel(),
                    child:
                    DropdownButton<String>(
                      value: dropdownProvider.selectedValue, // the currently selected title
                      // items: _filterOptions.map((itemone){
                      //   return DropdownMenuItem(
                      //       value: itemone,
                      //       child: Text(itemone)
                      //   );
                      // }).toList(),
                      items: [
                        DropdownMenuItem(child: Text('Today'),value: 'Today',),
                        DropdownMenuItem(child: Text('Yesterday'),value: 'Yesterday',),
                        DropdownMenuItem(child: Text('This Week'),value: 'This Week',),
                        DropdownMenuItem(child: Text('This Month'),value: 'This Month',),
                        DropdownMenuItem(child: Text('This Year'),value: 'This Year',),
                        DropdownMenuItem(child: Text('All'),value: 'All',),
                      ],
                      onChanged: (newValue) {
                        if (newValue != null) {
                          print(newValue);
                          // setState(() {
                          //   _selectedFilter = newValue;
                          // });
                          dropdownProvider.updateSelectedValue(newValue!);
                          _handleSearchFilter(
                            _searchController.text,
                            dropdownProvider.selectedValue.simplifyText(),
                          );
                        }
                      },


                    ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        clearDropdown();
                        dropdownProvider.updateSelectedValue('All');

                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),


                //this is og
                Text("Filter by Tiger name"),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: dropdownProvider.selectedTitle, // the currently selected title
                      items: _profileDataList.map((profileData) {
                        return DropdownMenuItem<String>(
                          value: profileData.title,
                          child: Text(profileData.title),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        dropdownProvider.updateSelectedTitle(newValue!);
                        // setState(() {
                        //   _selectedTitle = newValue!;
                        // });
                        filterData(newValue!, applyFilter: true);
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        clearDropdown();
                        dropdownProvider.updateSelectedTitle(null);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Number of tigers',
                      ),
                      keyboardType: TextInputType.number,
                      controller: tigersController,
                      onChanged: (String newValue) {
                        setState(() {
                          _selectedTigers = int.tryParse(newValue);
                        });
                        filterByTigers(_selectedTigers);
                      },
                    ),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Number of cubs',
                      ),
                      keyboardType: TextInputType.number,
                      controller: cubsController,
                      onChanged: (String newValue) {
                        setState(() {
                          _selectedCubs = int.tryParse(newValue);
                        });
                        filterByCubs(_selectedCubs);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                // Text('Selected options:'),
                // const SizedBox(height: 8.0),
                // Wrap(
                //   spacing: 8.0,
                //   runSpacing: 8.0,
                //   children: [
                //     for (final option in _selectedOptions)
                //       ElevatedButton(
                //         style: ElevatedButton.styleFrom(
                //           backgroundColor: Colors.green,
                //         ),
                //         onPressed: () {
                //           setState(() {
                //             if (_selectedOptions.contains(option)) {
                //               _selectedOptions.remove(option);
                //             } else {
                //               _selectedOptions.add(option);
                //             }
                //             _selectedFilter = _selectedOptions.join(',');
                //           });
                //           _handleSearchFilter(_searchController.text,
                //               _selectedFilter.simplifyText());
                //           // Navigator.pop(context);
                //         },
                //         child: Row(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             Text(option),
                //             const SizedBox(width: 4.0),
                //             Icon(Icons.clear, size: 16.0),
                //           ],
                //         ),
                //       ),
                //   ],
                // ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor:
            //         Colors.greenAccent.shade400, // Background color
            //     // Text Color (Foreground color)
            //   ),
            //   onPressed: () {
            //     setState(() {
            //       _selectedFilter = _selectedOptions.join(',');
            //     });
            //     _handleSearchFilter(
            //         _searchController.text, _selectedFilter.simplifyText());
            //     Navigator.pop(context);

            //     print(_selectedFilter.simplifyText());
            //   },
            //   child: Text('Apply'),
            // ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // if (_searchResult.isEmpty) {
    //   return const Center(child: CircularProgressIndicator());
    // }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: WillPopScope(child: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0.0), // hide the app bar
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
          ),
          body: Column(
            children: [
              Row(
                children: [

                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Forest Data List',
                          style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 30,
                        ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors
                                  .greenAccent.shade400, // Background color
                              // Text Color (Foreground color)
                            ),
                            onPressed: () async {
                              await exportToExcel();
                            },
                            child: Text("Export Data"))
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search',
                    hintText: 'Search by title, user name or user email',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.filter_list),
                      onPressed: _showFilterDialog,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    _handleSearchFilter(value, _selectedFilter.simplifyText());
                  },
                ),
              ),
              _searchResult.isEmpty
                  ? Text(
                "No result found....",
                style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              )
                  : Expanded(
                child: ListView.builder(
                  itemCount: _searchResult.length,
                  itemBuilder: (innerContext, index) {
                    final profileData = _searchResult[index];
                    return Card(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120.0,
                            height: 120.0,
                            child: Image.network(
                              profileData.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        profileData.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                    ],
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    DateFormat('MMM d, yyyy h:mm a')
                                        .format(profileData.datetime!
                                        .toDate()),
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    profileData.userName,
                                  ),
                                  const SizedBox(height: 5.0),
                                  Text(
                                    profileData.userEmail,
                                  ),
                                  const SizedBox(height: 8.0),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color.fromARGB(255,
                                          3, 8, 35), // Background color
                                      // Text Color (Foreground color)
                                    ),
                                    onPressed: () {
                                      debugPrint( "data" + profileData.toString() );

                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ForestDetail(
                                                    forestData: profileData,
                                                    changeIndex: widget.changeIndex,
                                                    changeData:  (TigerModel newData) {
                                                      setState(() {
                                                        _searchResult[index] = newData;
                                                      });
                                                    },
                                                    deleteData: (TigerModel data) {
                                                      setState(() {
                                                        _searchResult.removeWhere((element) => element.id == data.id);
                                                      });
                                                    },
                                                  )
                                          )
                                      );


                                    },
                                    label: const Text("View"),
                                    icon: const Icon(
                                        Icons.arrow_right_alt_outlined),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

        ),
        onWillPop: () => _onWillPop(context),));
  }

}
