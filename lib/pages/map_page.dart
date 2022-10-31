import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:sig/constant/app_constant.dart';
import 'package:sig/mapping/PointOfInterests.dart';
import 'InterestDetails.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  final pageController = PageController();
  int selectedIndex = 0;
  var currentLocation = AppConstants.myLocation;
  bool popupVisible = true;

  late final MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<PointOfInterests>>(
        future:
            fetchPointOfInterests("http://localhost:8000/api/v1/restaurants"),
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
                child: Text('Error: ${snapshot.error}'),
              ),
            ];
          } else if (snapshot.hasData) {
            print("my snapshot");
            print(snapshot.data);
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
                        center: currentLocation,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                        MarkerLayer(
                          markers: [
                            for (int i = 0; i < snapshot.data!.length; i++)
                              Marker(
                                height: 40,
                                width: 40,
                                point: snapshot.data![i].latLong,
                                builder: (_) {
                                  return GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        popupVisible = true;
                                        selectedIndex = i;
                                      });
                                      await Future.delayed(
                                          const Duration(milliseconds: 100),
                                          () {});

                                      currentLocation =
                                          snapshot.data![i].latLong;
                                      _animatedMapMove(currentLocation);
                                      // TODO sans le delay on ne peut pas jump d'un pop up a l'autre correctement.
                                      // Avec on a un effet bizarre ou on a d'abord le pop up de l'index 0 puis celui qui nous intéresse
                                      // pageController.animateToPage(
                                      pageController.jumpToPage(
                                        i,
                                        // duration: const Duration(milliseconds: 500),
                                        // curve: Curves.easeInOut,
                                      );
                                    },
                                    child: AnimatedScale(
                                      duration:
                                          const Duration(milliseconds: 500),
                                      scale: selectedIndex == i ? 1 : 0.7,
                                      child: AnimatedOpacity(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        opacity: selectedIndex == i ? 1 : 0.5,
                                        child: SvgPicture.asset(
                                          // snapshot.data![i].markerSVGModel,
                                          "assets/icons/map_marker.svg",
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                    //todo uncomment
                    bottomPopup(snapshot),
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

  void _animatedMapMove(LatLng destLocation) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final zoomTween =
        Tween<double>(begin: mapController.zoom, end: mapController.zoom);

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

  Visibility bottomPopup(AsyncSnapshot<List<PointOfInterests>> snapshot) {
    return (Visibility(
        visible: popupVisible,
        child: Positioned(
          left: 25,
          right: 25,
          bottom: 25,
          // height: MediaQuery.of(context).size.height * 0.3,
          height: 150,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (value) {
              selectedIndex = value;
              currentLocation = snapshot.data![value].latLong;
              _animatedMapMove(currentLocation);
              setState(() {});
            },
            itemCount: snapshot.data!.length,
            itemBuilder: (_, index) {
              final item = snapshot.data![index];

              return GestureDetector(
                  onTap: () => setState(() {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const InterestDetails()));
                      }),
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
                                    item.imageLink,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          IconButton(
                                            splashColor: Colors.transparent,
                                            highlightColor: Colors.transparent,
                                            icon: const Icon(
                                              Icons.close,
                                              color: Colors.black,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                popupVisible = false;
                                                selectedIndex = -1;
                                              });
                                            },
                                          ),
                                        ]),
                                    Container(
                                        margin: const EdgeInsets.only(
                                            left: 15, right: 5, bottom: 15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.only(
                                                  top: 20),
                                              child: const Text(
                                                "Ferme-Auberge du Ried du grand nord",
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                maxLines: 2,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const Text(
                                              "2 avenue de l'Europe, 67300 Schiltigheim",
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w100,
                                              ),
                                            ),
                                            Expanded(
                                                child: Row(
                                              children: [
                                                ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 0.0),
                                                  itemCount:
                                                      2, // todo add it to models eventually to be check with manager, it's the list of stars on the left hand
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return const Icon(
                                                      Icons.star,
                                                      size: 20,
                                                      color: Colors.orange,
                                                    );
                                                  },
                                                ),
                                                ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 0.0),
                                                  itemCount:
                                                      3, // todo add it to models eventually to be check with manager, it's the list of stars on the left hand
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return const Icon(
                                                      Icons.star,
                                                      size: 20,
                                                      color: Color.fromARGB(
                                                          255, 112, 110, 110),
                                                    );
                                                  },
                                                ),
                                              ],
                                            )),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    child: Stack(
                                                      children: <Widget>[
                                                        Positioned.fill(
                                                          child: Container(
                                                            decoration:
                                                                const BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors: <Color>[
                                                                  Color(
                                                                      0xFF0D47A1),
                                                                  Color(
                                                                      0xFF1976D2),
                                                                  Color(
                                                                      0xFF42A5F5),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          style: TextButton
                                                              .styleFrom(
                                                            foregroundColor:
                                                                Colors.white,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16.0),
                                                            textStyle:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16),
                                                          ),
                                                          onPressed: () {},
                                                          child: const Text(
                                                              'Itinéraires'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ]),
                                          ],
                                        ))
                                  ],
                                )),
                          ],
                        )),
                  ));
            },
          ),
        )));
  }
}
