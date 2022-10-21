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
          left: 0,
          right: 0,
          bottom: 2,
          height: MediaQuery.of(context).size.height * 0.3,
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
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  color: const Color.fromARGB(255, 30, 29, 29),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const InterestDetails()));
                    }),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      5, // todo add it to models eventually to be check with manager, it's the list of stars on the left hand
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      item.address,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                item.imageLink,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            width: 30,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      popupVisible = false;
                                    });
                                  },
                                )
                              ],
                            )),
                        const SizedBox(width: 15),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        )));
  }
}
