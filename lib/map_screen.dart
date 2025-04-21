// import 'package:car_rental/core/utils/themes/text_theme.dart';
import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final Location _location = Location();
  bool isLoading = true;
  LatLng? _currentLocation;
  final LatLng _tantaCollege = LatLng(30.7925, 31.0019); // Fixed destination
  LatLng? _destination;
  List<LatLng> _route = [];
  StreamSubscription<LocationData>? _locationSubscription;
  String? cityState;
  bool isAttended = false;
  @override
  void initState() {
    super.initState();
    _destination = _tantaCollege; // Set fixed destination
    _initializeLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    if (!await _checkRequestPermession()) return;

    _locationSubscription = _location.onLocationChanged.listen((
      LocationData locationData,
    ) async {
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
          isLoading = false;
        });

        if (_currentLocation != null) {
          //  cityState = await getCityStateFromLatLng(_currentLocation!);
          if (cityState != null) {
            print('Location: $cityState');
          }

          // await _fetchRoute();
        }
      }
    });
  }

  Future<bool> _checkRequestPermession() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return false;
    }
    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<void> _userCurrentLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current location is not available.')),
      );
    }
  }

  void errorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator())
              : FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(
                    26.8206,
                    30.8025,
                  ), // Egypt's center
                  initialZoom: 6.5, // Good zoom to view Egypt clearly
                  minZoom: 3,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  CurrentLocationLayer(
                    style: LocationMarkerStyle(
                      marker: DefaultLocationMarker(
                        child: Icon(Icons.location_pin, color: Colors.white),
                      ),
                      markerSize: Size(35, 35),
                      markerDirection: MarkerDirection.heading,
                    ),
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(
                          30.7860,
                          31.0009,
                        ), // Example: Tanta location
                        width: 150,
                        height: 80,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'DevCode Office',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 36,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_currentLocation != null && _route.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _route,
                          strokeWidth: 5,
                          color: Colors.red,
                        ),
                      ],
                    ),
                ],
              ),
          Positioned(
            top: 36,
            left: 6,
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            ),
          ),

          Positioned(
            bottom: 45,
            left: 10,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.blue,
              ),
              onPressed: () async {
                final result = await AttendanceService().takeAttendance(
                  context,
                );
                if (result == true) {
                  setState(() => isAttended = true);
                }
              },
              child: SizedBox(
                child: Text(
                  'Take attendance',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: _userCurrentLocation,
        backgroundColor: Colors.blue,
        child: Icon(Icons.my_location, size: 30, color: Colors.white),
      ),
    );
  }
}

class AttendanceService {
  final Location _location = Location();
  final LatLng officeLocation = LatLng(
    30.7887,
    30.9956,
  ); // Tanta College location

  Future<bool> takeAttendance(BuildContext context) async {
    final now = DateTime.now();
    final weekday = now.weekday;

    // Skip attendance on weekends
    if (weekday == DateTime.friday || weekday == DateTime.saturday) {
      _showMessage(context, "🚫 Attendance is not allowed on weekends.");
      return false;
    }

    final currentTime = TimeOfDay.fromDateTime(now);
    final currentMinutes = currentTime.hour * 60 + currentTime.minute;

    // Attendance window: 9:00 AM to 9:30 AM (540 to 570 minutes)
    const int attendanceStart = 9 * 60; // 540 minutes
    const int attendanceEnd = 9 * 60 + 30; // 570 minutes

    if (currentMinutes < attendanceStart) {
      _showMessage(context, "⏰ It's too early for attendance.");
      return false;
    }

    if (currentMinutes > attendanceEnd) {
      _showMessage(context, "⏰ Attendance time has ended.");
      return false;
    }

    // Location services check
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) serviceEnabled = await _location.requestService();

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return false;
    }

    final userLocation = await _location.getLocation();
    final userLatLng = LatLng(userLocation.latitude!, userLocation.longitude!);

    final distance = const Distance().as(
      LengthUnit.Meter,
      officeLocation,
      userLatLng,
    );

    if (distance <= 100) {
      //400
      // ignore: use_build_context_synchronously
      _showMessage(context, "✅ Attendance marked successfully!");
      return true;
    } else {
      _showMessage(
        // ignore: use_build_context_synchronously
        context,
        "📍 You are too far from the office (${distance.toStringAsFixed(1)} m)",
      );
      return false;
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }
}




  // Future<void> _fetchRoute() async {
  //   if (_currentLocation == null || _destination == null) return;
  //   final url = Uri.parse(
  //     'http://router.project-osrm.org/route/v1/driving/${_currentLocation!.longitude},${_currentLocation!.latitude};${_destination!.longitude},${_destination!.latitude}?overview=full&geometries=polyline',
  //   );
  //   final response = await http.get(url);
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final geometry = data['routes'][0]['geometry'];
  //     _decodePolyLine(geometry);
  //   } else {
  //     errorMessage('Failed to fetch route, try again later');
  //   }
  // }

  // Future<void> _decodePolyLine(String encodedPolyline) async {
  //   PolylinePoints polylinePoints = PolylinePoints();
  //   List<PointLatLng> decodedPoints = polylinePoints.decodePolyline(
  //     encodedPolyline,
  //   );
  //   setState(() {
  //     _route =
  //         decodedPoints
  //             .map((point) => LatLng(point.latitude, point.longitude))
  //             .toList();
  //   });
  // }