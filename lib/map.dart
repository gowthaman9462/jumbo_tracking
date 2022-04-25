
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'db.dart';
import 'model.dart';

class MapPage extends StatefulWidget {
  MapPage({Key? key, required this.list}) : super(key: key);
  Set<Marker> list;
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<MapPage> {
  DbManager dbManager = DbManager();
  late List<User> user;
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _center = LatLng(11.496057859832861, 77.27676158022257);
  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      child:GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: _center,
          zoom: 8.0,
        ),
        markers: widget.list
      )
    );
  }
}