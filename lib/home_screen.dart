import 'dart:async';
import 'dart:math' show asin, cos, sqrt;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_app/constant.dart';
import 'package:map_app/widgets/location_field_widget.dart';
import 'package:map_app/widgets/source_and_destination_image_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng sourceLocation = LatLng(12.9716, 77.5959);
  static const LatLng destination = LatLng(13.0196, 77.5854);
  LatLng carLocation = const LatLng(12.9716, 77.5959);

  // Maintain polyLine coordinates in a list
  List<LatLng> polyLineCoordinates = [];

  StreamController<List<LatLng>> polyLineStreamController =
      StreamController<List<LatLng>>();
  StreamController<LatLng> locationStreamController =
      StreamController<LatLng>();

  late BitmapDescriptor sourceIcon;
  late BitmapDescriptor destinationIcon;
  late BitmapDescriptor driverIcon;

  late String _darkMapStyle;

  ValueNotifier<double> progress =
      ValueNotifier(0.0); // Progress of car movement

  // Function to calculate the progress as a percentage (0.0 to 1.0)
  double calculateProgress(LatLng currentLocation) {
    double totalDistance = _calculateTotalDistance();
    double traveledDistance = _calculateTraveledDistance(currentLocation);
    return traveledDistance / totalDistance;
  }

  double _calculateTotalDistance() {
    double distance = 0.0;
    for (int i = 0; i < polyLineCoordinates.length - 1; i++) {
      distance += _coordinateDistance(
        polyLineCoordinates[i].latitude,
        polyLineCoordinates[i].longitude,
        polyLineCoordinates[i + 1].latitude,
        polyLineCoordinates[i + 1].longitude,
      );
    }
    return distance;
  }

  double _calculateTraveledDistance(LatLng currentLocation) {
    double traveled = 0.0;
    for (int i = 0; i < polyLineCoordinates.length - 1; i++) {
      LatLng point = polyLineCoordinates[i];
      if (point == currentLocation) {
        break;
      }
      traveled += _coordinateDistance(
        polyLineCoordinates[i].latitude,
        polyLineCoordinates[i].longitude,
        polyLineCoordinates[i + 1].latitude,
        polyLineCoordinates[i + 1].longitude,
      );
    }
    return traveled;
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // Mocking current location
  // You can also take user current location using [location] Package
  // and perform calculation according to that.
  void mockCurrentLocation() async {
    GoogleMapController googleMapController = await _controller.future;

    for (int i = 0; i < polyLineCoordinates.length - 1; i++) {
      LatLng nextPoint = polyLineCoordinates[i + 1];

      await Future.delayed(const Duration(milliseconds: 500), () {
        carLocation = nextPoint;
        locationStreamController.sink.add(carLocation);

        // Update progress
        progress.value = calculateProgress(carLocation);

        // Update camera position to follow the current location
        googleMapController.animateCamera(
          CameraUpdate.newLatLng(carLocation),
        );
      });
    }
  }

  // Function to draw polyLine between Source and Destination
  void getPolyLines() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: googleApiKey,
      request: PolylineRequest(
        origin: PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: TravelMode.driving,
      ),
    );

    polyLineCoordinates.clear();

    if (result.points.isNotEmpty) {
      for (final resultPoint in result.points) {
        polyLineCoordinates.add(
          LatLng(resultPoint.latitude, resultPoint.longitude),
        );
      }
    }

    polyLineStreamController.sink.add(polyLineCoordinates);
    loadAubergineTheme();
    mockCurrentLocation();
  }

  // Setting custom markers
  void customMarker() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      sourceIcon = await BitmapDescriptor.asset(
        ImageConfiguration.empty,
        "assets/icons/ironman.png",
        height: 40,
        width: 40,
      );
      destinationIcon = await BitmapDescriptor.asset(
        ImageConfiguration.empty,
        "assets/icons/batman.png",
        height: 40,
        width: 40,
      );
      driverIcon = await BitmapDescriptor.asset(
        ImageConfiguration.empty,
        "assets/icons/deadpool.png",
        height: 32,
        width: 32,
      );
      setState(() {});
    });
  }

  // Function to set Aubergine (Dark type) Theme, by loading it from asset
  Future loadAubergineTheme() async {
    _darkMapStyle =
        await rootBundle.loadString('assets/map_style/aubergine_theme.json');
  }

  @override
  void initState() {
    super.initState();
    customMarker();
    getPolyLines();
  }

  @override
  void dispose() {
    polyLineStreamController.close();
    locationStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.75,
              child: StreamBuilder<List<LatLng>>(
                stream: polyLineStreamController.stream,
                builder: (context, polyLineSnapshot) {
                  if (!polyLineSnapshot.hasData) {
                    return const Center(
                      child: Text(
                        "No Route Found",
                      ),
                    );
                  }
                  return StreamBuilder<LatLng>(
                    stream: locationStreamController.stream,
                    initialData: carLocation,
                    builder: (context, locationSnapshot) {
                      if (!locationSnapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      // Google Map with polyLine
                      return GoogleMap(
                        style: _darkMapStyle,
                        initialCameraPosition: CameraPosition(
                          target: locationSnapshot.data!,
                          zoom: 14,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('source'),
                            position: sourceLocation,
                            icon: sourceIcon,
                          ),
                          Marker(
                            markerId: const MarkerId('destination'),
                            position: destination,
                            icon: destinationIcon,
                          ),
                          Marker(
                            markerId: const MarkerId('driver'),
                            position: locationSnapshot.data!,
                            icon: driverIcon,
                          ),
                        },
                        polylines: {
                          Polyline(
                            polylineId: const PolylineId('route'),
                            points: polyLineSnapshot.data!,
                            color: customOrangeColor,
                            width: 5,
                          ),
                        },
                        onMapCreated: (mapController) {
                          _controller.complete(mapController);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            // Progress Indicator and Location info.
            Container(
              color: const Color(0xff293653),
              height: MediaQuery.sizeOf(context).height * 0.25,
              child: SingleChildScrollView(
                child: Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder(
                          valueListenable: progress,
                          builder: (context, value, _) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    right: 12,
                                    top: 12,
                                  ),
                                  child: LinearProgressIndicator(
                                    borderRadius: BorderRadius.circular(4),
                                    minHeight: 10,
                                    value: value,
                                    backgroundColor: customGreyColor,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            customOrangeColor),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                const Center(
                                  child: Text(
                                    "Deadpool is on the way...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            SourceAndDestinationImageWidget(),
                            SizedBox(
                              width: 12,
                            ),
                            // Source and Destination Field widget
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LocationFieldWidget(
                                  location: "Stark Tower",
                                ),
                                SizedBox(
                                  height: 18,
                                ),
                                LocationFieldWidget(location: "Wayne Manor")
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
