import 'dart:collection';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'main.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  var google_api_key = "AIzaSyA2ZgRY8jexy4fs2k9Xrxh2AHNmrDqwa0M";
  var lat = 31.2669991;
  var lon = 29.9983242;
  var myMarker = HashSet<Marker>();
  Location location =Location();
  List<LatLng> list = [];
  LocationData? currentLocation;

  void getCurrentLocation(){
    
    location.getLocation().then((location) {
     setState(() {
       currentLocation = location;
       getPolyPoints(currentLocation?.latitude, currentLocation?.longitude);
     });
    });

  }

  void readData(){
    DatabaseReference starCountRef =
    FirebaseDatabase.instance.ref('users');
    starCountRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map;
      setState(() {
        lat = data['Lat'];
        lon = data['long'];
        list.clear();
        getCurrentLocation();
      });
    });
  }

  void getPolyPoints(currentLat,currentLong) async{
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        google_api_key,
        PointLatLng(currentLat,currentLong),
        PointLatLng(lat,lon)
    );

    if(result.points.isNotEmpty){
      result.points.forEach((element) {
        list.add(LatLng(element.latitude, element.longitude));
      });
      setState(() {});
    }

  }

  @override
  void initState() {
    readData();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        child: Icon(Icons.logout,color: Colors.white,),
        onPressed: () async {
          await FirebaseAuth.instance.signOut().then((value) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (builder) => const MyApp())));
        },
      ),
      body:
      currentLocation == null ?
      const Center(child: Text("Loading"),):
      Container(
              alignment: Alignment.center,
              child: GoogleMap(
                initialCameraPosition:  CameraPosition(
                  zoom: 14,
                  target: LatLng(currentLocation!.latitude!,currentLocation!.longitude!)
                ),
                markers: {
                  Marker(
                      markerId: MarkerId("current"),
                      position: LatLng(currentLocation!.latitude!,currentLocation!.longitude!)
                  ),
                  Marker(
                      markerId: MarkerId("1"),
                      position:LatLng(lat,lon)
                  ),
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId("route"),
                    points: list,
                    width: 5,
                    color: Colors.blue
                  )
                },
              ),
            ),
    );
  }
}