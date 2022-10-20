/*
* Allow to map an api to a single common interface
*/
class MarkerMapping {
  final String latitude = "";
  final String longitude = "";
  final String imageLink = "";
  final String description = "";
  final String title = "";
  final String address = "";
  final String markerSVGModel= "";

  const MarkerMapping(
      {
        required latitude,
        required longitude,
        required imageLink,
        required description,
        required title,
        required address,
        required markerSVGModel
      });
}

