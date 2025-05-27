import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:route_tracker/views/home_view.dart';

void main(){
  runApp(RouteTracker());
}
class RouteTracker extends StatelessWidget {
  const RouteTracker({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeView(),
    );
  }
}
