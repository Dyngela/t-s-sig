import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:sig/constant/app_constant.dart';
import 'package:sig/mapping/PointOfInterests.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'InterestDetails.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

// late AsyncSnapshot<List<PointOfInterests>> _snapshot;

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final pageController = PageController();

  bool isBottomPopupVisible =
      false; // true = show the bottom popup information of the marker
  PointOfInterests? currentPoint; // the current Point that user clicked in

  // list of all the points in the map that we fetched from the API
  List<PointOfInterests> listPointOfInterests = [];
  int selectedMarkerIndex = -1; // the selected index in the list of point

  // to access to the context for the different widget for Navigator push
  late BuildContext contextBuild;
  late final MapController mapController;

  // to manage the textfield
  final TextEditingController _typeAheadController =
      TextEditingController(); // take care of the text in the textfield
  final SuggestionsBoxController _suggestionsBoxController =
      SuggestionsBoxController(); // take care of the suggestion shown in the textfield

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    contextBuild = context;
    return Scaffold(
      body: FutureBuilder<List<PointOfInterests>>(
        future: PointOfInterests.fetchPointOfInterests(AppConstants.apiUrl),
        builder: (BuildContext context,
            AsyncSnapshot<List<PointOfInterests>> snapshot) {
          List<Widget> children = [];
          if (snapshot.hasError) {
            children = <Widget>[
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                    "Mince... Une erreur s'est produite : ${snapshot.error}"),
              ),
            ];
          } else if (snapshot.hasData) {
            print(snapshot.data);
            listPointOfInterests = snapshot.requireData;
            children = <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                            minZoom: 5,
                            maxZoom: 18,
                            zoom: 11,
                            center: currentPoint?.latLong ??
                                AppConstants.myLocation),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          ),
                          MarkerClusterLayerWidget(
                            /* cluster map marker */
                            options: MarkerClusterLayerOptions(
                              spiderfyCircleRadius: 80,
                              spiderfySpiralDistanceMultiplier: 2,
                              circleSpiralSwitchover: 12,
                              maxClusterRadius: 120,
                              rotate: true,
                              size: const Size(40, 40),
                              anchor: AnchorPos.align(AnchorAlign.center),
                              fitBoundsOptions: const FitBoundsOptions(
                                padding: EdgeInsets.all(50),
                                maxZoom: 15,
                              ),
                              markers:
                                  listMarker(), // create all markers points
                              builder: (context, markers) {
                                return Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.blue),
                                  child: Center(
                                    child: Text(
                                      markers.length.toString(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ]),
                    topSearchBar, // to search a specific marker point on the map
                    bottomPopup(), // to display info about a marker point
                  ],
                ),
              )
            ];
          } else {
            children = const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              ),
            ];
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: children,
            ),
          );
        },
      ),
    );
  }

  // List of all markers that will be shown on the map
  List<Marker> listMarker() {
    List<Marker> marker = [];
    for (int i = 0; i < listPointOfInterests.length; i++) {
      marker.add(Marker(
        height: 40,
        width: 40,
        point: listPointOfInterests[i].latLong,
        builder: (_) {
          return GestureDetector(
            onTap: () async {
              // when we click on the marker
              setState(() {
                isBottomPopupVisible = true;
                selectedMarkerIndex = i;
                currentPoint = listPointOfInterests[i];
              });

              await Future.delayed(const Duration(milliseconds: 100), () {});

              _animatedMapMove(currentPoint!.latLong, 15);
            },
            child: AnimatedScale(
              duration: const Duration(milliseconds: 500),
              scale: selectedMarkerIndex == i
                  ? 1
                  : 0.6, // if clicked on the marker, we increase the height of marker
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: (selectedMarkerIndex == i || selectedMarkerIndex == -1
                    ? 1
                    : 0.5),
                child: SvgPicture.asset(
                  // snapshot.data![i].markerSVGModel,
                  "assets/icons/map_marker.svg",
                ),
              ),
            ),
          );
        },
      ));
    }

    return marker;
  }

  // top search bar to look for a place
  late Widget topSearchBar = SafeArea(
    child: Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(30))),
        child: TypeAheadField<PointOfInterests?>(
          suggestionsBoxVerticalOffset: 3,
          hideSuggestionsOnKeyboardHide: false,
          suggestionsBoxController: _suggestionsBoxController,
          suggestionsBoxDecoration: const SuggestionsBoxDecoration(
              constraints: BoxConstraints(
                maxHeight: 200.0,
              ),
              borderRadius: BorderRadius.all(Radius.circular(30))),
          textFieldConfiguration: TextFieldConfiguration(
            controller: _typeAheadController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30.0))),
              hintText: ' Saisissez votre recherche...',
              hintStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w200,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          suggestionsCallback: (pattern) async {
            return PointOfInterests.getSuggestions(
                pattern, listPointOfInterests);
          },
          itemBuilder: (context, PointOfInterests? suggestion) {
            final point = suggestion!;

            return ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                child: ListTile(
                  leading: const Icon(Icons.place_outlined),
                  title: Text(point.title),
                ));
          },
          noItemsFoundBuilder: (context) => const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'Aucun lieu de trouvé.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
          onSuggestionSelected: (PointOfInterests? suggestion) {
            PointOfInterests point = suggestion!;
            _typeAheadController.text = suggestion.title;

            showBottomPopupState(); // hide current bottom popup
            if (!isBottomPopupVisible) showBottomPopupState(); // display again
            currentPoint = point;
            selectedMarkerIndex = listPointOfInterests
                .indexWhere((element) => element.latLong == point.latLong);

            _animatedMapMove(point.latLong, 18);
          },
        ),
      ),
    ),
  );

  // to make the bottom popup visible or unvisible
  void showBottomPopupState() {
    setState(() {
      isBottomPopupVisible = !isBottomPopupVisible;
    });
  }

  // Bottom popup that will be shown when we click on a marker
  Visibility bottomPopup() {
    return (Visibility(
      visible: isBottomPopupVisible,
      child: Positioned(
        left: 25,
        right: 25,
        bottom: 25,
        height: 150,
        child: PageView.builder(
          controller: pageController,
          itemBuilder: (_, index) {
            final PointOfInterests point = currentPoint!;

            return GestureDetector(
              onTap: () => setState(
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          InterestDetails(pointOfInterests: point),
                    ),
                  );
                },
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                child: Container(
                  height: 200,
                  width: 200,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.only(
                              left: 15, top: 15, bottom: 15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              point.imageLink,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Stack(
                          children: [
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      // if we want to close the popup
                                      setState(() {
                                        isBottomPopupVisible = false;
                                        selectedMarkerIndex = -1;
                                        _typeAheadController.text = "";
                                      });
                                    },
                                  ),
                                ]),
                            Container(
                              margin: const EdgeInsets.only(
                                  left: 15, right: 5, bottom: 4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Text(
                                      point.title,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      maxLines: 2,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    point.address,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w100,
                                    ),
                                  ),
                                  // Expanded(
                                  //     child: Row(
                                  //   children: [
                                  //     ListView.builder(
                                  //       scrollDirection:
                                  //           Axis.horizontal,
                                  //       shrinkWrap: true,
                                  //       padding:
                                  //           const EdgeInsets.only(
                                  //               top: 0.0),
                                  //       itemCount:
                                  //           2, // todo add it to models eventually to be check with manager, it's the list of stars on the left hand
                                  //       itemBuilder:
                                  //           (BuildContext context,
                                  //               int index) {
                                  //         return const Icon(
                                  //           Icons.star,
                                  //           size: 20,
                                  //           color: Colors.orange,
                                  //         );
                                  //       },
                                  //     ),
                                  //     ListView.builder(
                                  //       scrollDirection:
                                  //           Axis.horizontal,
                                  //       shrinkWrap: true,
                                  //       padding:
                                  //           const EdgeInsets.only(
                                  //               top: 0.0),
                                  //       itemCount:
                                  //           3, // todo add it to models eventually to be check with manager, it's the list of stars on the left hand
                                  //       itemBuilder:
                                  //           (BuildContext context,
                                  //               int index) {
                                  //         return const Icon(
                                  //           Icons.star,
                                  //           size: 20,
                                  //           color: Color.fromARGB(
                                  //               255, 112, 110, 110),
                                  //         );
                                  //       },
                                  //     ),
                                  //   ],
                                  // )),
                                  Container(
                                    margin: const EdgeInsets.only(top: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      12), // <-- Radius
                                            ),
                                          ),
                                          child: const Text('Itinéraire'),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ));
  }

  // to make an animation and a zoom when we click on a marker on the map
  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }
}
