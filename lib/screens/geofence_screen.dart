import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GeofenceScreen extends StatefulWidget {
  const GeofenceScreen({super.key});
  @override
  State<GeofenceScreen> createState() => _GeofenceScreenState();
}
class _GeofenceScreenState extends State<GeofenceScreen> {
  static const LatLng _initialPosition = LatLng(30.0444, 31.2357);
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  double _radius = 500;
  Set<Marker> _markers = {};
  Circle? _geofenceCircle;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  Future<void> _getCurrentLocation() async {
    LocationPermission permission;

    permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng currentLatLng = LatLng(
      position.latitude,
      position.longitude,
    );

    setState(() {
      _selectedLocation = currentLatLng;

      _markers = {
        Marker(
          markerId: const MarkerId('current_location'),
          position: currentLatLng,
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      };

      _updateGeofenceCircle();
    });

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(currentLatLng, 16),
    );
  }

  void _updateGeofenceCircle() {
    if (_selectedLocation != null) {
      _geofenceCircle = Circle(
        circleId: const CircleId('geofence'),
        center: _selectedLocation!,
        radius: _radius,
        fillColor: Colors.blue.withOpacity(0.1),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;

      _markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          infoWindow: const InfoWindow(title: 'Selected Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      };

      _updateGeofenceCircle();
    });
  }
  void _goToCurrentLocation() async {
    await _getCurrentLocation();
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      Navigator.pop(context, {
        'location': _selectedLocation,
        'radius': _radius,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _initialPosition,
              zoom: 16,
            ),
            markers: _markers,
            circles: _geofenceCircle != null ? {_geofenceCircle!} : {},
            onTap: _onMapTap,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
          ),

          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              children: [
                _buildCircleButton(
                  Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedLocation != null
                                ? 'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}'
                                : 'Search location...',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 380,
            right: 20,
            child: _buildCircleButton(
              Icons.navigation,
              color: Colors.blue,
              onTap: _goToCurrentLocation,
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 300,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Text("Radius: ${_radius.toInt()} m"),

                  Slider(
                    value: _radius,
                    min: 100,
                    max: 1000,
                    onChanged: (val) {
                      setState(() {
                        _radius = val;
                        _updateGeofenceCircle();
                      });
                    },
                  ),

                  const Spacer(),

                  ElevatedButton(
                    onPressed: _confirmLocation,
                    child: const Text("Set Location Reminder"),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(IconData icon,
      {Color color = Colors.grey, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}