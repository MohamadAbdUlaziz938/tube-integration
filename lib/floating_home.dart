import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:floating/floating.dart';

class FloatingUpperHome extends StatelessWidget {
  const FloatingUpperHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return FloatingHome();
                },
              ));
            },
            child: Text("Floating view")),
      ),
    );
  }
}

class FloatingHome extends StatefulWidget {
  const FloatingHome({super.key});

  @override
  _FloatingHomeState createState() => _FloatingHomeState();
}

class _FloatingHomeState extends State<FloatingHome>
    with WidgetsBindingObserver {
  final floating = Floating();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    print("dispose $FloatingHome");
    WidgetsBinding.instance.removeObserver(this);
    floating.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    print("life cycle --> $lifecycleState");

    if (lifecycleState == AppLifecycleState.inactive) {
      floating.enable(aspectRatio: Rational.vertical());
    }
  }


  Future<void> enablePip(BuildContext context) async {
    final rational = Rational.landscape();
    final screenSize =
        MediaQuery.of(context).size * MediaQuery.of(context).devicePixelRatio;
    final height = screenSize.width ~/ rational.aspectRatio;

    final status = await floating.enable(
      aspectRatio: rational,
      sourceRectHint: Rectangle<int>(
        0,
        (screenSize.height ~/ 2) - (height ~/ 2),
        screenSize.width.toInt(),
        height,
      ),
    );
    debugPrint('PiP enabled? $status');
  }

  @override
  Widget build(BuildContext context) => PiPSwitcher(
        floating: floating,
        childWhenDisabled: Scaffold(
          appBar: AppBar(title: Text("Floating home"),),
          body: const Center(child: Text("Disabled")),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FutureBuilder<bool>(
            future: floating.isPipAvailable,
            initialData: false,
            builder: (context, snapshot) => snapshot.data ?? false
                ? FloatingActionButton.extended(
                    onPressed: () => enablePip(context),
                    label: const Text('Enable PiP'),
                    icon: const Icon(Icons.picture_in_picture),
                  )
                : const Card(
                    child: Text('PiP unavailable'),
                  ),
          ),
        ),
        childWhenEnabled: const Scaffold(
          body: Text("Enable"),
        ),
      );
}
