import 'dart:async';

import 'package:admin_web_panel/global/trip_var.dart';
import 'package:admin_web_panel/methods/common_methods.dart';
import 'package:admin_web_panel/methods/manage_drivers_methods.dart';
import 'package:admin_web_panel/methods/push_notifiction_service.dart';
import 'package:admin_web_panel/models/online_nearby_drivers.dart';
import 'package:admin_web_panel/widgets/info_dialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DispatchPage extends StatefulWidget {

  static const String id = "\webPageDispatch";

  const DispatchPage({super.key});

  @override
  State<DispatchPage> createState() => _DispatchPageState();
}

class _DispatchPageState extends State<DispatchPage> {
//reusable widget for rows

  final DatabaseReference onlineDriversRef = FirebaseDatabase.instance.ref().child("onlineDrivers");
  List<OnlineNearbyDrivers>? availableNearbyOnlineDriversList;
  DatabaseReference? tripRequestRef;
  String stateOfApp = "normal";

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  CommonMethods cMethods = CommonMethods();

  Future<void> fetchOnlineDrivers() async {
    try {
      DatabaseEvent snapshot = await onlineDriversRef.once();
      if (snapshot.snapshot.value != null) {
        Map dataMap = snapshot.snapshot.value as Map;
        List<OnlineNearbyDrivers> driversList = [];

        dataMap.forEach((key, value) {
          print('Key: $key, Value: $value');
          String uidDriver = key;
          //double latDriver = (value['l']['0'] as num).toDouble();
          //double lngDriver = (value['l']['1'] as num).toDouble();

          OnlineNearbyDrivers driver = OnlineNearbyDrivers(
            uidDriver: uidDriver,
            latDriver: 0,
            lngDriver: 0,
          );
          print(driver);
          sendNotificationToDriver(driver);
          //availableNearbyOnlineDriversList = availableNearbyOnlineDriversList ?? []..add(driver);
        });
      }

    } catch (error) {
      print("Error fetching online drivers: $error");
    }
  }

  makeTripRequest() {
    tripRequestRef = FirebaseDatabase.instance.ref().child('tripRequests').push();
    var pickUpLocation = pickUpTextEditingController.text;
    var dropOffDestinationLocation = dropOffTextEditingController.text;

    Map dataMap = {
      "tripID": tripRequestRef!.key,
      "publishDataTime": DateTime.now().toString(),
      "userName": nameTextEditingController.text,
      "userPhone": phoneTextEditingController.text,
      "userID": "",
      "pickUpLatLng": "",
      "dropOffLatLng": "",
      "pickUpAddress": pickUpLocation,
      "dropOffAddress": dropOffDestinationLocation,

      "driverID": "waiting",
      "carDetails": "",
      "driverLocation": "",
      "driverName": "",
      "driverPhone" : "",
      "driverPhoto": "",
      "fareAmount": "",
      "status": "new",
    };

    tripRequestRef!.set(dataMap);
  }

  noDriverAvailable() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) =>InfoDialog(
        title: "No Driver Available",
        description: "No Driver found in nearby location, Please try again shortly",
      ),
    );
  }

  searchDriver() {
    if (availableNearbyOnlineDriversList == null || availableNearbyOnlineDriversList!.isEmpty) {
      noDriverAvailable();
      return;
    }
    var currentDriver = availableNearbyOnlineDriversList![0];
    //send notification to this currentDriver - currentDriver means selected driver
    sendNotificationToDriver(currentDriver);
    availableNearbyOnlineDriversList!.removeAt(0);
  }

  sendNotificationToDriver(OnlineNearbyDrivers currentDriver) {
    //update driver's newTripStatus - assign tripID to current driver
    DatabaseReference currentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("newTripStatus");
    currentDriverRef.set(tripRequestRef!.key);

    //get current driver device recognition token
    DatabaseReference tokenOfCurrentDriverRef = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentDriver.uidDriver.toString())
        .child("deviceToken");

    tokenOfCurrentDriverRef.once().then((dataSnapshot) {
      if(dataSnapshot.snapshot.value!= null) {
        String deviceToken = dataSnapshot.snapshot.value.toString();
        //send notification
        PushNotificationService.sendNotificationToSelectedDriver(
            deviceToken,
            context,
            tripRequestRef!.key.toString()
        );
      }
      else {
        return;
      }
      const oneTickPerSec = Duration(seconds: 1);
      var timerCountDown = Timer.periodic(oneTickPerSec, (timer) {
        requestTimeoutDriver = requestTimeoutDriver -1;
        //when trip request is not requesting means trip request cancelled - stop timer
        if(stateOfApp != "requesting") {
          timer.cancel();
          currentDriverRef.set("cancelled");
          currentDriverRef.onDisconnect();
          requestTimeoutDriver = 20;
        }
        //when trip request is accepted by online nearest driver
        currentDriverRef.onValue.listen((dataSnapshot) {
          if(dataSnapshot.snapshot.value.toString() == "accepted") {
            timer.cancel();
            currentDriverRef.onDisconnect();
            requestTimeoutDriver = 20;
          }
        });
        //if 20 sec passed - send notification to next nearest online available driver
        if(requestTimeoutDriver == 0) {
          currentDriverRef.set("timeout");
          timer.cancel();
          currentDriverRef.onDisconnect();
          requestTimeoutDriver = 20;

          //send notification to next nearest online available driver
          searchDriver();
        }
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Dispatching",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 18,),

              Divider(
                color: Colors.black87,
              ),

              //text fields + button
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [

                    TextField(
                      controller: nameTextEditingController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: "Passenger name",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: phoneTextEditingController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: "Passenger phone",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: pickUpTextEditingController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: "Pick Up Location",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 22,),

                    TextField(
                      controller: dropOffTextEditingController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: "Drop Off Location",
                        labelStyle: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height: 32,),

                    ElevatedButton(
                      onPressed: () {
                        //availableNearbyOnlineDriversList = ManageDriversMethods.nearbyOnlineDriversList;
                        //print(availableNearbyOnlineDriversList);
                        searchDriver();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 80, vertical: 10)
                      ),
                      child: const Text(
                          "Send request to Drivers"
                      ),
                    ),

                    const SizedBox(height: 12,),
                    //text button
                    TextButton(
                        onPressed: () {

                        },
                        child: const Text(
                          "Schedule a taxi appointment",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        )
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
