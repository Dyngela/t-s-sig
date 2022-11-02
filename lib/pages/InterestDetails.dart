import 'package:flutter/material.dart';
import 'package:sig/pages/map_page.dart';
import 'package:carousel_slider/carousel_slider.dart';

class InterestDetails extends StatefulWidget {
  const InterestDetails({super.key});

  @override
  State<StatefulWidget> createState() => _InterestDetailsState();
}

// to access to the context for the different widget for Navigator push
late BuildContext _context;
int currentIndex = 0;

final List<String> imgList = [
  'assets/images/restaurant_1.jpg',
  'assets/images/restaurant_2.jpg',
  'assets/images/restaurant_3.jpg',
  'assets/images/restaurant_4.jpg',
  'assets/images/restaurant_5.jpg'
];

class _InterestDetailsState extends State<InterestDetails> {
  @override
  void initState() {
    super.initState();
    currentIndex = 0;
  }

  changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    _context = context;

    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          const SizedBox(height: 10),
          headerSection,
          adressSection,
          const SizedBox(height: 20),
          carousel,
          infoSection,
          textDetailSection,
        ],
      )),
    );
  }
}

Widget headerSection = Container(
    padding: const EdgeInsets.only(top: 10.0),
    child: Row(
      children: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color(0x00d9d9d9),
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(18),
          ),
          onPressed: () {
            Navigator.push(
              _context,
              MaterialPageRoute(builder: (context) => const MapPage()),
            );
            const MapPage();
          },
          child: Image.asset('assets/icons/icon_go_back.png'),
        ),
        const SizedBox(width: 10),
        const Text(
          'Pizza nico le K',
          style: TextStyle(
              color: Colors.black, fontSize: 36, fontWeight: FontWeight.bold),
        ),
      ],
    ));

Widget adressSection = Container(
    margin: const EdgeInsets.only(top: 10.0, left: 60.0),
    child: Row(
      children: const [
        Text(
          "2 Av. de l'Europe, 67300 Schiltigheim",
          style: TextStyle(
              color: Colors.black, fontSize: 15, fontWeight: FontWeight.w100),
        )
      ],
    ));

Widget infoSection = Container(
    margin: const EdgeInsets.only(top: 30.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text(
            "Téléphone:",
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
          ),
          Text(
            "03.88.49.65.77",
            style: TextStyle(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text(
            "Distance:",
            style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.normal),
          ),
          Text(
            "2,4km",
            style: TextStyle(
                color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Avis:",
            style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.normal),
          ),
          Row(
            children: [
              const Text(
                "3",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 3),
              Image.asset('assets/icons/icon_star.png')
            ],
          )
        ]),
      ],
    ));

Widget textDetailSection = Container(
    margin: const EdgeInsets.only(top: 30.0, bottom: 30),
    padding: const EdgeInsets.only(left: 50, right: 50),
    child: Row(
      children: const [
        Flexible(
          child: Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum",
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.normal,
            ),
          ),
        )
      ],
    ));

Widget carousel = CarouselSlider(
  options: CarouselOptions(
    height: 200.0,
    aspectRatio: 16 / 9,
    viewportFraction: 0.8,
    initialPage: 0,
    enableInfiniteScroll: false,
    reverse: false,
    autoPlayCurve: Curves.fastOutSlowIn,
    enlargeCenterPage: true,
  ),
  items: imgList.map((i) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: AssetImage(i),
                fit: BoxFit.cover,
              ),
            ));
      },
    );
  }).toList(),
);
