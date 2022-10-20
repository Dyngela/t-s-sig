import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:sig/constant/app_constant.dart';


class PointOfInterests {
  final LatLng latLong;
  final String description;
  final String imageLink;
  final String title;
  final String address;
  final String markerSVGModel;

  const PointOfInterests(
      {
        required this.latLong,
        required this.description,
        required this.imageLink,
        required this.title,
        required this.markerSVGModel,
        this.address = '',
      });


  @override
  String toString() {
    return "${latLong}";
  }

  factory PointOfInterests.fromJson(Map<String, dynamic> json) {

    var latitude = json[AppConstants.latitude];
    var longitude = json[AppConstants.longitude];
    return PointOfInterests(
      latLong: LatLng(latitude, longitude),
      // description: json[AppConstants.mapPoints.description] ?? "",
      // imageLink: json[AppConstants.mapPoints.imageLink] ?? "",
      // title: json[AppConstants.mapPoints.title] ?? "",
      // address: json[AppConstants.address] ?? "",
      description: "descrip",
      imageLink: "image link",
      title: "title",
      address: "ZZ",
      markerSVGModel: "assets/icons/map_marker.svg",
    );
  }

}

Future<List<PointOfInterests>> fetchPointOfInterests(String apiUrl) async {
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final parsed = json.decode(response.body).cast<Map<String, dynamic>>();
    var returned = parsed.map<PointOfInterests>((json) => PointOfInterests.fromJson(json)).toList();
    print(returned);
    return returned;
  } else {
    throw Exception('Failed to load markers');
  }
}



