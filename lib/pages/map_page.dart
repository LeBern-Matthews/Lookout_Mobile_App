import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {


  final Location _locationController =Location();

  ///static const LatLng _kGooglePlex =LatLng (37.43296265331129, -122.08832357078792);
  ///static const LatLng _kingstown =LatLng (13.1600249, -61.2248157);
  //static const LatLng _fortcharlotte =LatLng (13.15970342578315, -61.23965802761441);
  //static const LatLng _epages =LatLng (13.162705095707283, -61.23992396101061);
  static const LatLng _miltonKato =LatLng (13.158670985689088, -61.230774818593694);
  static const LatLng _georgetown =LatLng (13.282249027118223, -61.121786306699725);

  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition==null ? const Center(child: Text("Loading..."),): GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition!, 
          zoom: 10),
        markers: {
          Marker(
            markerId: MarkerId("_currentLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position:_currentPosition!
          ),
          Marker(
            markerId: MarkerId("_sourceLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position:_miltonKato
          ),
                    Marker(
            markerId: MarkerId("_targetLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position:_georgetown
          ),
        },
          )
    );
  }
  Future<void> getLocationUpdates () async{
  bool serviceEnabled;
  PermissionStatus permissionGranted;


  serviceEnabled = await _locationController.serviceEnabled();
  if (serviceEnabled){
    serviceEnabled= await _locationController.requestService();
  } else {
    return;
  }

  permissionGranted =await _locationController.hasPermission();
  if(permissionGranted==PermissionStatus.denied){
    permissionGranted= await _locationController.requestPermission();
        if(permissionGranted!=PermissionStatus.granted){
          return;
    }
  }
  _locationController.onLocationChanged.listen((LocationData currentLocation){
    if(currentLocation.latitude!= null && currentLocation.longitude!= null){
      setState(() {
        _currentPosition=LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });
      print(_currentPosition);
    }
  });
  }
}