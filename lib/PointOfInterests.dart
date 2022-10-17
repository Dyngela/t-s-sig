import 'dart:convert';
import 'package:http/http.dart' as http;


class PointOfInterests {
  final num latitude;
  final num longitude;
  final String description;
  final String imageLink;
  final String title;
  final String address;

  const PointOfInterests(
      {
        required this.latitude,
        required this.longitude,
        required this.description,
        required this.imageLink,
        required this.title,
        this.address = '',
      });


  @override
  String toString() {
    return "${this.latitude}\n${this.longitude}";
  }

  factory PointOfInterests.fromJson(Map<String, dynamic> json) {
    return PointOfInterests(
      latitude: json['latitude'],
      longitude: json['longitude'],
      description: json['description'],
      imageLink: json['imageLink'],
      title: json['title'],
      address: json['address'],
    );
  }
}


class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  @override
  String toString() {
    return this.title;
  }

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
    );
  }
}

Future<Album> fetchAlbum() async {
  final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));

  if (response.statusCode == 200) {
    return Album.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load album');
  }
}