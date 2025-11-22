import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? _currentPosition;
  bool _isLoading = false;
  bool _locationEnabled = false;
  List<dynamic> _hospitals = [];

  final String baseUrl = "http://localhost:8080/haelin-app"; // backend URL
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

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

      // Move map to current location
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        13.0,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied.")),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _fetchNearbyHospitals(double lat, double lon) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/map/hospitals?lat=$lat&lon=$lon&radius=5000"),
      );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : LatLng(6.9271, 79.8612),
              initialZoom: 13.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.haelin',
              ),
              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(
                          _currentPosition!.latitude, _currentPosition!.longitude),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                  for (var h in _hospitals)
                    Marker(
                      point: LatLng(h['lat'] ?? 0.0, h['lon'] ?? 0.0),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.local_hospital,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // 🔹 Draggable Bottom Sheet for Hospitals
          if (_locationEnabled)
            DraggableScrollableSheet(
              initialChildSize: 0.2,
              minChildSize: 0.1,
              maxChildSize: 0.6,
              builder: (context, scrollController) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black26, blurRadius: 10, offset: Offset(0, -2))
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
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: _hospitals.length,
                                itemBuilder: (context, index) {
                                  final name =
                                      _hospitals[index]['tags']?['name'] ??
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
}
