import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {


  Location _locationController =new Location();

  ///static const LatLng _kGooglePlex =LatLng (37.43296265331129, -122.08832357078792);
  ///static const LatLng _kingstown =LatLng (13.1600249, -61.2248157);
  static const LatLng _fortcharlotte =LatLng (13.15970342578315, -61.23965802761441);
  static const LatLng _epages =LatLng (13.162705095707283, -61.23992396101061);

  LatLng? _currentPosition = null;

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
            position:_fortcharlotte
          ),
                    Marker(
            markerId: MarkerId("_targetLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position:_epages
          ),
        },
          )
    );
  }
  Future<void> getLocationUpdates () async{
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;


  _serviceEnabled = await _locationController.serviceEnabled();
  if (_serviceEnabled){
    _serviceEnabled= await _locationController.requestService();
  } else {
    return;
  }

  _permissionGranted =await _locationController.hasPermission();
  if(_permissionGranted==PermissionStatus.denied){
    _permissionGranted= await _locationController.requestPermission();
        if(_permissionGranted!=PermissionStatus.granted){
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