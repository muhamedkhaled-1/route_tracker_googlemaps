import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:route_tracker/utils/google_maps_place_service.dart';
import 'package:route_tracker/utils/location_service.dart';
import 'package:route_tracker/views/widgets/Custom_list_view.dart';
import 'package:route_tracker/views/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

import '../models/location_info/lat_lng.dart';
import '../models/location_info/location.dart';
import '../models/location_info/location_info.dart';
import '../models/place_autocomplete_model/place_autocomplete_model.dart';
import '../models/routes_model/routes_model.dart';
import '../utils/map_services.dart';
import '../utils/routes_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late MapServices mapServices;
  late TextEditingController textEditingController;
  late CameraPosition initialCameraPosition;
  late Location location;
  late GoogleMapController googleMapController;
  late Uuid uuid;
  Set<Marker> markers = {};
  List<PlaceModel> places=[];
  Set<Polyline> polyLines = {};
  String? sessionToken;
  late LatLng currentLocation;
  late LatLng desintation;
  @override
  void initState() {
    uuid=Uuid();
    mapServices = MapServices();
    textEditingController=TextEditingController();
    initialCameraPosition = CameraPosition(
      target: LatLng(0, 0),
    );
    location = Location();
    fetchPredictions();
    super.initState();
  }
  void fetchPredictions() {
    textEditingController.addListener(() async {
      sessionToken ??= uuid.v4();
      await mapServices.getPredictions(
          input: textEditingController.text,
          sesstionToken: sessionToken!,
          places: places);
      setState(() {});
    });
  }
    @override
    void dispose() {
      textEditingController.dispose();
      super.dispose();
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              markers: markers,
                onMapCreated: (controller) {
                  googleMapController = controller;
                  updateCurrentLocation();
                },
                initialCameraPosition: initialCameraPosition),
          Column(
            children: [
              CustomTextField(
                textEditingController: textEditingController,
              ),
              CustomListView(
                onPlaceSelect: (placeDetailsModel) async {
                  textEditingController.clear();
                  places.clear();

                  sessionToken = null;
                  setState(() {});
                  desintation = LatLng(
                      placeDetailsModel.geometry!.location!.lat!,
                      placeDetailsModel.geometry!.location!.lng!);

                  var points = await mapServices.getRouteData(
                      currentLocation: currentLocation,
                      desintation: desintation);
                  mapServices.displayRoute(points,
                      polyLines: polyLines,
                      googleMapController: googleMapController);
                  setState(() {});
                },
                places: places,
                mapServices: mapServices,
              )
            ],
          )
          ],
        ),
      ),
    );
  }

  void updateCurrentLocation() async {
    try {
      currentLocation = await mapServices.updateCurrentLocation(
          googleMapController: googleMapController, markers: markers);
      setState(() {});
    } on LocationServiceException catch (e) {
      // TODO:
    } on LocationPermissionException catch (e) {
      // TODO :
    } catch (e) {
      // TODO:
    }
  }
}
