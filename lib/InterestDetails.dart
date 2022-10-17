import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InterestDetails extends StatefulWidget {
  const InterestDetails({super.key});

  @override
  State<StatefulWidget> createState() => _InterestDetailsState();
}

class _InterestDetailsState extends State<InterestDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget body() {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: body(),
    );
  }
}
