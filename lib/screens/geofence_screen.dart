import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeofenceScreen extends StatefulWidget {
  const GeofenceScreen({super.key});

  @override
  State<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends State<GeofenceScreen> {
  // Initial map position (Apple Park Visitor Center as default)
  static const LatLng _initialPosition = LatLng(37.335886, -122.009444);

  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  double _radius = 500;
  bool _isMapReady = false;

  // Default markers
  Set<Marker> _markers = {
    const Marker(
      markerId: MarkerId('default_location'),
      position: _initialPosition,
      infoWindow: InfoWindow(title: 'Apple Park Visitor Center'),
    ),
  };

  // Circle for geofence visualization
  Circle? _geofenceCircle;

  @override
  void initState() {
    super.initState();
    _selectedLocation = _initialPosition;
    _updateGeofenceCircle();
  }

  void _updateGeofenceCircle() {
    if (_selectedLocation != null) {
      setState(() {
        _geofenceCircle = Circle(
          circleId: const CircleId('geofence'),
          center: _selectedLocation!,
          radius: _radius,
          fillColor: Colors.blue.withOpacity(0.1),
          strokeColor: Colors.blue.shade400,
          strokeWidth: 2,
        );
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _isMapReady = true;
    });
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
    // In a real app, you would get the current location from GPS
    // For now, we'll animate to a sample location
    if (_mapController != null && _selectedLocation != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(_selectedLocation!));
    }
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
          // 1. Google Map
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
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // 2. Top Search Bar
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedLocation != null
                                ? 'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}'
                                : 'Search location...',
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_selectedLocation != null)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedLocation = null;
                                _markers.clear();
                                _geofenceCircle = null;
                              });
                            },
                            child: const Icon(
                              Icons.cancel,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Current Location Button
          Positioned(
            bottom: 380,
            right: 20,
            child: _buildCircleButton(
              Icons.navigation,
              color: Colors.blue,
              onTap: _goToCurrentLocation,
            ),
          ),

          // 4. Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 350,
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Selected Location",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              Text(
                                _selectedLocation != null
                                    ? ' ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}'
                                    : ' Tap on map to select',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Icon(
                          Icons.bookmark_border,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Geofence Radius",
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "${_radius.toInt()} m",
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _radius,
                    min: 100,
                    max: 1000,
                    activeColor: Colors.blue,
                    inactiveColor: Colors.grey[200],
                    onChanged: (val) => setState(() {
                      _radius = val;
                      _updateGeofenceCircle();
                    }),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "100m",
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      Text(
                        "1km",
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: _selectedLocation != null
                          ? _confirmLocation
                          : null,
                      icon: const Icon(Icons.location_on),
                      label: const Text(
                        "Set Location Reminder",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        disabledBackgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(
    IconData icon, {
    Color color = Colors.grey,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}
