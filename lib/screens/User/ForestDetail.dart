import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:forestapp/common/models/TigerModel.dart';
import 'package:forestapp/screens/Admin/EditTigerAdmin.dart';
import 'package:forestapp/screens/User/EditTigerUser.dart';
import 'package:forestapp/screens/User/ForestMapScreen.dart' as mp;
import 'package:intl/intl.dart';
import 'ForestDataScreen.dart';

// class ForestDetail extends StatelessWidget {
//   final TigerModel forestData;
//
//   const ForestDetail({Key? key, required this.forestData}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0.0,
//         flexibleSpace: Container(
//             height: 90,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.green, Colors.greenAccent],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             )),
//         title: Text(forestData.title),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(
//                     builder: (context) => const ForestDataScreen()),
//                 (route) => false);
//           },
//         ),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           AspectRatio(
//             aspectRatio: 16 / 9,
//             child: Image.network(
//               forestData.imageUrl,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   forestData.title,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 24,
//                   ),
//                 ),
//                 SizedBox(height: 8),
//                 Text(forestData.description),
//                 SizedBox(height: 8),
//                 Row(
//                   children: [
//                     CircleAvatar(
//                       backgroundImage: NetworkImage(forestData.userImage),
//                     ),
//                     SizedBox(width: 8),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(forestData.userName),
//                         Text(forestData.userEmail),
//                       ],
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                   DateFormat('MMM d, yyyy h:mm a')
//                       .format(forestData.datetime!.toDate()),
//                 ),
//                 SizedBox(height: 8),
//                 Text(
//                     'Latitude: ${forestData.location.latitude}, Longitude: ${forestData.location.longitude}'),
//
//                 SizedBox(height: 8),
//                 Text('Number Of Cubs: ${forestData.noOfCubs}'),
//                 SizedBox(height: 8),
//                 Text('Number Of Tigers: ${forestData.noOfTigers}'),
//                 SizedBox(height: 8),
//                 Text('Remark: ${forestData.remark}'),
//                 SizedBox(height: 8),
//                 Text('Guard Contact: ${forestData.userContact}'),
//                 SizedBox(height: 16),
//
//                 Row(
//                   children: [
//                     ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             Colors.green.shade400, // Background color
//                         // Text Color (Foreground color)
//                       ),
//                       onPressed: () {
//                         Navigator.of(context).pushAndRemoveUntil(
//                             MaterialPageRoute(
//                               builder: (context) => mp.ForestMapScreen(
//                                 latitude: forestData.location.latitude,
//                                 longitude: forestData.location.longitude,
//                                 userName: forestData.userName,
//                                 tigerName: forestData.title,
//                               ),
//                             ),
//                             (route) => false);
//                       },
//                       label: const Text("Show on Map"),
//                       icon: const Icon(Icons.arrow_right_alt_outlined),
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             Colors.red.shade400, // Background color
//                         // Text Color (Foreground color)
//                       ),
//                       onPressed: () async {
//                         final confirm = await showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             title: const Text('Confirm Deletion'),
//                             content: const Text(
//                                 'Are you sure you want to delete this user?'),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context, false),
//                                 child: const Text('Cancel'),
//                               ),
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context, true),
//                                 child: const Text('Delete'),
//                               ),
//                             ],
//                           ),
//                         );
//                         if (confirm == true) {
//                           try {
//                             final snapshot = await FirebaseFirestore.instance
//                                 .collection('forestdata')
//                                 .where('user_email',
//                                     isEqualTo: forestData.userEmail)
//                                 .get();
//                             if (snapshot.docs.isNotEmpty) {
//                               await snapshot.docs.first.reference.delete();
//                               Navigator.of(context).pushAndRemoveUntil(
//                                   MaterialPageRoute(
//                                       builder: (context) =>
//                                           const ForestDataScreen()),
//                                   (route) => false);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('User deleted successfully.'),
//                                 ),
//                               );
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(
//                                   content: Text('User not found.'),
//                                 ),
//                               );
//                             }
//                           } catch (e) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Error deleting user: $e'),
//                               ),
//                             );
//                           }
//                         }
//                       },
//                       child: Text("Delete"),
//
//                     ),
//                     SizedBox(
//                       width: 10,
//                     ),
//                      ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             Colors.green.shade400, // Background color
//                         // Text Color (Foreground color)
//                       ),
//                       onPressed: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) =>
//                                     EditTigerUser(tiger: this.forestData)));
//                       },
//                       child: const Text("Edit"),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 // Expanded(
//                 //   child: WebViewWidget(
//                 //       controller: WebViewController()
//                 //         ..loadRequest(
//                 //           Uri.parse(
//                 //               'https://www.google.com/maps/search/?api=1&query=${forestData.location.latitude.toString()},${forestData.location.longitude.toString()}'),
//                 //         )
//                 //         ..setJavaScriptMode(JavaScriptMode.unrestricted)),
//                 // ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


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
  late TigerModel tigerData;

  @override
  void initState( ) {
    super.initState();

    tigerData = widget.forestData;
  }

  void _changeData( TigerModel newData ) {
    // updating The curerent screen
    setState(() {
      tigerData = newData;
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
    return  WillPopScope(child: Scaffold(
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
        title: Text(tigerData.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigator.of(context).pushAndRemoveUntil(
            //     MaterialPageRoute(
            //         builder: (context) => const ForestDataScreen()),
            //         (route) => false);
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
                tigerData.imageUrl,
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
                            tigerData.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(tigerData.description),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(tigerData.userImage),
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tigerData.userName),
                                  Text(tigerData.userEmail),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            DateFormat('MMM d, yyyy h:mm a')
                                .format(tigerData.datetime!.toDate()),
                          ),
                          SizedBox(height: 8),
                          Text(
                              'Latitude: ${tigerData.location.latitude}, Longitude: ${tigerData.location.longitude}'),

                          SizedBox(height: 8),
                          Text('Number Of Cubs: ${tigerData.noOfCubs}'),
                          SizedBox(height: 8),
                          Text('Number Of Tigers: ${tigerData.noOfTigers}'),
                          SizedBox(height: 8),
                          Text('Remark: ${tigerData.remark}'),
                          SizedBox(height: 8),
                          Text('Guard Contact: ${tigerData.userContact}'),
                          SizedBox(height: 8),
                          Text('Description: ${tigerData.description}'),
                          SizedBox(height: 8),
                          Text('range: ${tigerData.range}'),
                          SizedBox(height: 8),
                          Text('round: ${tigerData.round}'),
                          SizedBox(height: 8),
                          Text('Beat: ${tigerData.beat}'),
                        ]
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
                                latitude: tigerData.location.latitude,
                                longitude: tigerData.location.longitude,
                                userName: tigerData.userName,
                                tigerName: tigerData.title,
                                changeIndex: widget.changeIndex,
                                datetime: tigerData.datetime,
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
                                  onPressed: () => Navigator.pop(context, true),
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

                                widget.deleteData( tigerData );
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
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => EditTigerUser(
                                        tiger: tigerData,
                                        changeData: ( TigerModel newData ) {
                                          // setState(() {
                                          //   tigerData = newData;
                                          // });

                                          _changeData(newData);
                                  }, changeIndex: (int ) { widget.changeIndex; },

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
            icon: Icon(Icons.person),
            label: 'Profile',
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
    ), onWillPop: () => _onWillPop(context));
  }
}


