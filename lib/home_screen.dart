import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  double _lat = 0;
  double _lon = 0;
  Position? _lastPosition;

  @override
  void initState() {
    super.initState();
    initValues();
    startLocationUpdates();
  }

  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition();

    setState(() {
      _lat = position.latitude;
      _lon = position.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          zoom: 17,
          target: LatLng(_lat, _lon),
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,
        polylines: _polylines,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        compassEnabled: true,
        myLocationButtonEnabled: true,
        myLocationEnabled: true,
      ),
    );
  }

  void initValues() {
    _determinePosition();
  }

  Future<void> startLocationUpdates() async {
    const Duration interval = Duration(seconds: 10);
    Geolocator.getPositionStream().listen((Position position) {
      if (_lastPosition == null ||
          Geolocator.distanceBetween(_lastPosition!.latitude,
              _lastPosition!.longitude, position.latitude, position.longitude) >
              10) {
        setState(() {
          _lat = position.latitude;
          _lon = position.longitude;
        });

        _updateMarkerPosition(LatLng(_lat, _lon));
        _updatePolyline(LatLng(_lat, _lon));

        _lastPosition = position;
      }
    });
  }

  void _updateMarkerPosition(LatLng position) {
    setState(() {
      _markers = {
        Marker(
          markerId: MarkerId('myLocation'),
          position: position,
          infoWindow: InfoWindow(
            title: 'My current location',
            snippet: 'Lat: $_lat, Lng: $_lon',
          ),
        ),
      };
    });
  }

  void _updatePolyline(LatLng position) {
    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId('route'),
          points: List.from(
              _polylines.isNotEmpty ? _polylines.first.points : [])..add(position),
          color: Colors.blue,
          width: 5,
        ),
      );
    });
  }
}
