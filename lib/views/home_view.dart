import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:route_tracker/utils/google_maps_service.dart';
import 'package:route_tracker/utils/location_service.dart';
import 'package:route_tracker/views/widgets/Custom_list_view.dart';
import 'package:route_tracker/views/widgets/custom_text_field.dart';

import '../models/place_autocomplete_model/place_autocomplete_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late GoogleMapsPlacesService googleMapsPlacesService;
  late TextEditingController textEditingController;
  late CameraPosition initialCameraPosition;
  late Location location;
  late GoogleMapController googleMapController;
  late LocationService locationService;
  Set<Marker> markers = {};
  List<PlaceModel> places=[];
  @override
  void initState() {
    googleMapsPlacesService=GoogleMapsPlacesService();
    textEditingController=TextEditingController();
    initialCameraPosition = CameraPosition(
      target: LatLng(0, 0),
    );
    location = Location();
    locationService=LocationService();
    fetchPredictions();
    super.initState();
  }
  void fetchPredictions(){

      textEditingController.addListener(() async{
        if(textEditingController.text.isNotEmpty){
        var result=await googleMapsPlacesService.getPredictions(input: textEditingController.text);
        places.clear();
        places.addAll(result);
        print(places);
        setState(() {
          
        });
        }},);

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
                  updateCurentLocation();
                },
                initialCameraPosition: initialCameraPosition),
          Column(
            children: [
              CustomTextField(
                textEditingController: textEditingController,
              ),
              CustomListView(places: places)
            ],
          )
          ],
        ),
      ),
    );
  }

  void updateCurentLocation() async{
    var locationData=await locationService.getLocation();
    LatLng currentPoistion =
    LatLng(locationData.latitude!, locationData.longitude!);
    Marker currentLocationMarker = Marker(
      markerId: const MarkerId('my location'),
      position: currentPoistion,
    );
    CameraPosition myCurrentCameraPoistion = CameraPosition(
        target: currentPoistion,
        zoom: 16,);
    googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(myCurrentCameraPoistion));
    markers.add(currentLocationMarker);
    setState(() {});
  }
}
