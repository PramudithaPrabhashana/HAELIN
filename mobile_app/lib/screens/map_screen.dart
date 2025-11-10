import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Position? _currentPosition;
  bool _isLoading = false;
  bool _locationEnabled = false;
  List<dynamic> _hospitals = [];

  final String baseUrl = "http://10.0.2.2:8080/haelin-app"; // backend URL

  Future<void> _enableLocation() async {
    setState(() => _isLoading = true);

    final status = await Permission.location.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      setState(() {
        _currentPosition = position;
        _locationEnabled = true;
      });

      await _fetchNearbyHospitals(position.latitude, position.longitude);
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude), 13));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Location permission denied."),
      ));
    }

    setState(() => _isLoading = false);
  }

  Future<void> _fetchNearbyHospitals(double lat, double lon) async {
    try {
      final response = await http.get(Uri.parse(
          "$baseUrl/map/hospitals?lat=$lat&lon=$lon&radius=5000"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> hospitals = [];

        if (data is Map && data['elements'] is List) {
          hospitals = data['elements'].where((element) {
            return element['tags'] != null &&
                element['tags']['amenity'] == 'hospital';
          }).toList();
        }

        setState(() => _hospitals = hospitals);
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  Set<Marker> _buildMarkers() {
    final markers = <Marker>{};

    if (_currentPosition != null) {
      markers.add(Marker(
        markerId: const MarkerId('me'),
        position:
            LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: "You are here"),
      ));
    }

    for (var h in _hospitals) {
      final tags = h['tags'];
      final name = tags['name'] ?? 'Hospital';
      final lat = h['lat'] ?? 0.0;
      final lon = h['lon'] ?? 0.0;

      markers.add(Marker(
        markerId: MarkerId(name),
        position: LatLng(lat, lon),
        infoWindow: InfoWindow(title: name),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(6.9271, 79.8612),
              zoom: 12,
            ),
            onMapCreated: (controller) => mapController = controller,
            myLocationEnabled: _locationEnabled,
            markers: _buildMarkers(),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),

          // 🔹 Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildIconButton(Icons.arrow_back, () {}),
                  const Image(
                    image: AssetImage('assets/logo.png'),
                    height: 40,
                  ),
                  _buildIconButton(Icons.menu, () {}),
                ],
              ),
            ),
          ),

          // 🔹 Search bar
          Positioned(
            top: 80,
            left: 30,
            right: 30,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF286BB5), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.black54),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Colombo",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),

          // 🔹 Draggable Bottom Sheet (Hospitals)
          if (_locationEnabled)
            DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.1,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, -2))
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 6,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const Text(
                        "Nearby Hospitals",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF286BB5),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _hospitals.isEmpty
                            ? const Center(
                                child: Text(
                                  "No hospitals found nearby.",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: _hospitals.length,
                                itemBuilder: (context, index) {
                                  final name = _hospitals[index]['tags']
                                          ?['name'] ??
                                      'Unnamed Hospital';
                                  return _buildHospitalTile(name);
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // 🔹 Enable Location button
          if (!_locationEnabled)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _enableLocation,
                  icon: const Icon(Icons.my_location, color: Colors.white),
                  label: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Enable Location"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF286BB5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHospitalTile(String name) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_hospital, color: Color(0xFF286BB5)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
          )
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87),
        onPressed: onPressed,
      ),
    );
  }
}
