import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../location/user_location.dart';

class MapsView extends StatelessWidget {
  final LatLng kantorCoordinates;
  final UserLocation userLocation;

  MapsView({
    required this.kantorCoordinates,
    required this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
          target: kantorCoordinates,
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId('absen_location'),
            position: kantorCoordinates,
            infoWindow: const InfoWindow(title: 'Lokasi Absen'),
          ),
          Marker(
            markerId: const MarkerId('user_location'),
            position: LatLng(userLocation.latitude, userLocation.longitude),
            infoWindow: const InfoWindow(title: 'Lokasi Anda'),
          ),
        },
        onMapCreated: (GoogleMapController controller) {
          // Pengendalian peta
        },
      ),
    );
  }
}
