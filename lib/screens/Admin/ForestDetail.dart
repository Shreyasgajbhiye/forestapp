import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/common/models/TigerModel.dart';
import 'package:forestapp/screens/Admin/EditTigerAdmin.dart';
import 'package:forestapp/screens/Admin/ForestMapScreen.dart' as mp;
import 'package:intl/intl.dart';

class ForestDetail extends StatefulWidget {
  final Function(int) changeIndex;
  final Function( TigerModel ) changeData;
  final Function( TigerModel ) deleteData;
  TigerModel forestData;

  ForestDetail({
    super.key,
    required this.changeIndex,
    required this.forestData,
    required this.changeData,
    required this.deleteData
  });

  @override
  State<ForestDetail> createState() => _ForestDetailState();
}

class _ForestDetailState extends State<ForestDetail> {
  void _changeData( TigerModel newData ) {
    setState(() {
      widget.forestData = newData;
    });

    // also updating the parent screen
    widget.changeData( newData );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    Navigator.pop(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(widget.forestData.title),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.of(context).push(
            //     MaterialPageRoute(
            //         builder: (context) => ForestDataScreen(changeIndex: changeIndex,)),
            //     );
            Navigator.pop(context);
          },
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                widget.forestData.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.forestData.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(widget.forestData.description),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(widget.forestData.userImage),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.forestData.userName),
                                  Text(widget.forestData.userEmail),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            DateFormat('MMM d, yyyy h:mm a')
                                .format(widget.forestData.datetime!.toDate()),
                          ),
                          SizedBox(height: 8),
                          Text(
                              'Latitude: ${widget.forestData.location.latitude}, Longitude: ${widget.forestData.location.longitude}'),

                          SizedBox(height: 8),
                          Text('Number Of Cubs: ${widget.forestData.noOfCubs}'),
                          SizedBox(height: 8),
                          Text('Number Of Tigers: ${widget.forestData.noOfTigers}'),
                          SizedBox(height: 8),
                          Text('Remark: ${widget.forestData.remark}'),
                          SizedBox(height: 8),
                          Text('Round: ${widget.forestData.round}'),
                          SizedBox(height: 8),
                          Text('Range: ${widget.forestData.range}'),
                          SizedBox(height: 8),
                          Text('Beat: ${widget.forestData.beat}'),
                          SizedBox(height: 8),
                          Text('Guard Contact: ${widget.forestData.userContact}'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),


                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.green.shade400, // Background color
                          // Text Color (Foreground color)
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => mp.ForestMapScreen(
                                latitude: widget.forestData.location.latitude,
                                longitude: widget.forestData.location.longitude,
                                userName: widget.forestData.userName,
                                tigerName: widget.forestData.title,
                                changeIndex: widget.changeIndex,
                                datetime: widget.forestData.datetime,
                              ),
                            ),
                          );
                        },
                        label: const Text("Show on Map"),
                        icon: const Icon(Icons.arrow_right_alt_outlined),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.red.shade400, // Background color
                          // Text Color (Foreground color)
                        ),
                        onPressed: () async {
                          final confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Confirm Deletion'),
                              content: const Text(
                                  'Are you sure you want to delete this user?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context,true),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            try {
                              final snapshot = await FirebaseFirestore.instance.collection('forestdata')
                                  .doc(widget.forestData.id)
                                  .get();

                              if (snapshot.exists) {
                                await snapshot.reference.delete();
                                // Navigator.of(context).pushAndRemoveUntil(
                                //     MaterialPageRoute(
                                //         builder: (context) =>
                                //          ForestDataScreen(changeIndex: (int ) {  },)),
                                //         (route) => false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('User deleted successfully.'),
                                  ),
                                );

                                Navigator.pop(context);

                                widget.deleteData( widget.forestData );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('User not found.'),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error deleting user: $e'),
                                ),
                              );
                            }
                          }
                        },
                        child: Text("Delete"),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Colors.green.shade400, // Background color
                          // Text Color (Foreground color)
                        ),
                        onPressed: () async{
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditTigerAdmin(
                                    tiger: widget.forestData,
                                    changeIndex: widget.changeIndex,
                                    changeData: _changeData,
                                  )
                              )

                          );

                        },
                        child: const Text("Edit"),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
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
        onTap: (index){
          widget.changeIndex(index);
          Navigator.pop(context);
        },
      ),
    ),
        onWillPop: () => _onWillPop(context));
  }
}
