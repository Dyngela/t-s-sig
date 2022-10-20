import 'package:latlong2/latlong.dart';
import 'package:sig/mapping/Mapping.dart';

class AppConstants {
  static final myLocation = LatLng(48.580002, 7.750000); //london

  static const MarkerMapping mapPoints = MarkerMapping
    (latitude: "lat", longitude: "lon", imageLink: "", description: "", title: "", address: "streetName", markerSVGModel: "assets/icons/map_marker.svg");
  static const MarkerMapping markerDetails = MarkerMapping
    (latitude: "lat", longitude: "long", imageLink: "", description: "", title: "", address: "", markerSVGModel: "assets/icons/map_marker.svg");

  static const String latitude = "lat";
  static const String longitude = "lon";
  static const String address = "streetName";

}
