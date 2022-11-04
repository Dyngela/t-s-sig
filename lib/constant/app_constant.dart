import 'package:latlong2/latlong.dart';
import 'package:sig/mapping/Mapping.dart';

class AppConstants {
  // for android emulator
  //static const apiUrl = "http://10.0.2.2:8000/api/v1/restaurants";
  // for chrome emulator
  static const apiUrl = "http://localhost:8000/api/v1/restaurants";
  static final myLocation = LatLng(48.580002, 7.750000); //london

  // not working, unable to init static const object with dart. TODO find a clever workaround
  static const MarkerMapping mapPoints = MarkerMapping(
      latitude: "lat",
      longitude: "lon",
      imageLink: "",
      description: "",
      title: "streetName",
      address: "",
      markerSVGModel: "assets/icons/map_marker.svg");
  static const MarkerMapping markerDetails = MarkerMapping(
      latitude: "lat",
      longitude: "long",
      imageLink: "",
      description: "",
      title: "",
      address: "",
      markerSVGModel: "assets/icons/map_marker.svg");

  static const String latitude = "lat";
  static const String longitude = "lon";
  static const String title = "streetName";
  static const String address = "adresseLieu";
}
