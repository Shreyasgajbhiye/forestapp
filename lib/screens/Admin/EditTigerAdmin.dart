// ignore_for_file: unused_field, library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forestapp/common/models/TigerModel.dart';

import '../../common/themeHelper.dart';

class EditTigerAdmin extends StatefulWidget {
  final Function(TigerModel) changeData;
  final TigerModel tiger;
  final Function(int) changeIndex;

  const EditTigerAdmin({
    super.key,
    required this.changeIndex,
    required this.tiger,
    required this.changeData
  });


  //const EditTigerAdmin({super.key, required this.tiger});

  @override
  _EditTigerAdminState createState() => _EditTigerAdminState();
}

class _EditTigerAdminState extends State<EditTigerAdmin> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  late int _noOfCubs;
  late int _noOfTigers;
  String _remark = '';

  Map<String, dynamic>? selectedRange;
  Map<String, dynamic>? selectedRound;
  Map<String, dynamic>? selectedBt;

  Map<String, List<dynamic>> dynamicLists = {};

  Future<void> fetchDynamicLists() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('dynamic_lists')
        .get();

    final userData = userSnapshot.docs;

    for( var item in userData ) {
      dynamicLists[item.id] = item['values'];
    }

    // setting the dynamic list for conflict with value none
    print('round');
    print(dynamicLists['range']);
    print(widget.tiger.range);

    setState(() {
      // adding the element in case it is not present, just to prevent the app from
      // crashing
      selectedRange = dynamicLists['range']?.where( (range) => range['name'] == widget.tiger.range ).first;
      selectedRound = dynamicLists['round']?.where( (round) => round['name'] == widget.tiger.round ).first;
      selectedBt = dynamicLists['beat']?.where( (beat) => beat['name'] == widget.tiger.beat ).first;
    });
  }

  final CollectionReference _userRef =
      FirebaseFirestore.instance.collection('forestdata');

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void _onItemTapped(int index) {
    widget.changeIndex( index );
    Navigator.of(context).pop();
  }

  Future<bool> _onWillPop(BuildContext context) async {
    Navigator.pop(context);
    return false;
  }

  @override
  void initState( ) {
    super.initState();
    fetchDynamicLists();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
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
        // title: const Text('Pench MH'),
        title: const Center(
          child: Text(
            'Edit Tiger',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.of(context).pushAndRemoveUntil(
            //     MaterialPageRoute(
            //         builder: (context) => UserScreen()),
            //         (route) => false);
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        // elevation: 0.0,
      ),
      body: SafeArea(
        child: dynamicLists.length == 0 ?Center( child: CircularProgressIndicator.adaptive()) : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a tiger name';
                  }
                  return null;
                },
                initialValue: widget.tiger.title,
                onSaved: (value) {
                  _name = value!;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an Description';
                  }
                  return null;
                },
                initialValue: widget.tiger.description,
                onSaved: (value) {
                  _description = value!;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Number of cubs',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid number of cubs';
                  }
                  return null;
                },
                initialValue: widget.tiger.noOfCubs.toString(),
                onSaved: (value) {
                  _noOfCubs = int.parse(value!);
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'No. of Tigers',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Tigers';
                  }
                  return null;
                },
                initialValue: widget.tiger.noOfTigers.toString(),
                onSaved: (value) {
                  _noOfTigers = int.parse(value!);
                },
              ),
              const SizedBox(height: 16.0),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Remark',
                  border: OutlineInputBorder(),
                ),
                // keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a remark here';
                  }
                  return null;
                },
                initialValue: widget.tiger.remark,
                onSaved: (value) {
                  _remark = value!;
                },
              ),
              SizedBox(height: 16,),
              Text(
                "Range",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownButtonFormField(
                decoration: ThemeHelper().textInputDecoration(
                    'Range', 'Enter Range'
                ),
                value: selectedRange,
                items: dynamicLists['range']?.map<DropdownMenuItem<Map<String, dynamic>>>( (range) => DropdownMenuItem<Map<String, dynamic>>(
                  value: range,
                  child: Text( range['name'] ),
                ) ).toList(),
                onChanged: (Map<String, dynamic>? value) {
                  setState(() {
                    selectedRange = value;
                    selectedRound = dynamicLists['round']?.where( (round) => round['range_id'] == selectedRange!['id'] ).toList().first;
                    selectedBt = dynamicLists['beat']?.where( (beat) => beat['round_id'] == selectedRound!['id'] ).toList().first;
                  });
                },
              ),

              const SizedBox(
                height: 10,
              ),
              Text(
                "Round",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownButtonFormField(
                decoration: ThemeHelper().textInputDecoration(
                    'Round', 'Enter Round'
                ),
                value: selectedRound,
                items: dynamicLists['round']!.where( (round) => round['range_id'] == selectedRange!['id'] ).map<DropdownMenuItem<Map<String, dynamic>>>(
                      (round) => DropdownMenuItem<Map<String, dynamic>>(
                    child: Text(round['name']),
                    value: round,
                  ),
                )
                    .toList(),
                onChanged: (Map<String, dynamic>? value) {
                  setState(() {
                    selectedRound = value;
                    selectedBt = dynamicLists['beat']?.where( (beat) => beat['round_id'] == selectedRound!['id'] ).toList().first;
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),

              Text(
                "Beats",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownButtonFormField(
                decoration: ThemeHelper().textInputDecoration(
                    'Beats', 'Enter Beats'
                ),
                value: selectedBt,
                items: dynamicLists['beat']!.where( (beat) => beat['round_id'] == selectedRound!['id'] ).map<DropdownMenuItem<Map<String, dynamic>>>( (beat) => DropdownMenuItem<Map<String, dynamic>>(
                  child: Text(beat['name'] ),
                  value: beat,
                ) ).toList(),
                onChanged: (Map<String, dynamic>? value) {
                  selectedBt = value;
                },
              ),
              const SizedBox(
                height: 10,
              ),

              const SizedBox(height: 16.0),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Update the tiger data in the Firebase Firestore
                    final CollectionReference tigersRef =
                    FirebaseFirestore.instance.collection('forestdata');

                    final Map<String, dynamic> userData = {
                      'title': _name,
                      "range" : selectedRange,
                      "round" : selectedRound,
                      'beat' : selectedBt,
                      'description': _description,
                      'number_of_cubs': _noOfCubs,
                      'number_of_tiger': _noOfTigers,
                      'remark': _remark
                    };
                    try {
                      await tigersRef
                          .where('id', isEqualTo: widget.tiger.id)
                          .get()
                          .then((querySnapshot) {
                        querySnapshot.docs.forEach((doc) {
                          tigersRef.doc(doc.id).update(userData);
                        });
                      });

                      // Navigator.of(context).pushAndRemoveUntil(
                      //     MaterialPageRoute(
                      //         builder: (context) =>
                      //              ForestDataScreen(changeIndex: widget.changeIndex,)),
                      //     (route) => false);
                      //Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tiger updated successfully'),
                        ),
                      );

                      // updating the data on previous screens
                      TigerModel newData = TigerModel(
                          id: widget.tiger.id,
                          range: selectedRange!['name'],
                          round: selectedRound!['name'],
                          beat: selectedBt!['name'],
                          title: _name,
                          description: _description,
                          imageUrl: widget.tiger.imageUrl,
                          userName: widget.tiger.userName,
                          userEmail: widget.tiger.userEmail,
                          location: widget.tiger.location,
                          noOfCubs: _noOfCubs,
                          noOfTigers: _noOfTigers,
                          remark: _remark,
                          userContact: widget.tiger.userContact,
                          userImage: widget.tiger.userImage,
                          datetime: widget.tiger.datetime
                      );

                      // sending the new data to previous screen
                      widget.changeData( newData );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $error'),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Save'),
              )
            ],
          ),
        ),
      ),
    ),
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
