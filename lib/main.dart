import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import 'floating_home.dart';
import 'overlay_home.dart';
import 'overlays/true_caller_overlay.dart';

void main() {
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrueCallerOverlay(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Live stream',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FloatingUpperHome(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late YoutubePlayerController _youTubeCtr;
  final formKey = GlobalKey<FormState>();
  late final TextEditingController tubeLink;
  bool _isInPiPMode = false;
  bool _isPlayerReady = false;

  void tubeListener() {
    debugPrint("player state: ${_youTubeCtr.value.playerState}");
  }

  @override
  void initState() {
    super.initState();
    tubeLink = TextEditingController();
    _youTubeCtr = YoutubePlayerController(
      initialVideoId: 'iLnmTe5Q2Qw',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    _youTubeCtr.addListener(tubeListener);
  }

  @override
  void dispose() {
    _youTubeCtr.dispose();
    tubeLink.dispose();
    super.dispose();
  }

  Color _getStateColor(PlayerState state) {
    switch (state) {
      case PlayerState.unknown:
        return Colors.grey[700]!;
      case PlayerState.unStarted:
        return Colors.pink;
      case PlayerState.ended:
        return Colors.red;
      case PlayerState.playing:
        return Colors.blueAccent;
      case PlayerState.paused:
        return Colors.orange;
      case PlayerState.buffering:
        return Colors.yellow;
      case PlayerState.cued:
        return Colors.blue[900]!;
      default:
        return Colors.blue;
    }
  }

  void _enterPiPMode() async {
    if (!_isInPiPMode) {
      //_isInPiPMode = await FlutterOverlayWindow.enterPictureInPictureMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // print("---onExitFullScreen---");
        // print(DeviceOrientation.values);
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        //SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      onEnterFullScreen: () {},
      player: YoutubePlayer(
        controller: _youTubeCtr,
        showVideoProgressIndicator: true,
        onReady: () {
          _isPlayerReady = true;
        },
        topActions: [
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _youTubeCtr.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
        bottomActions: [
          CurrentPosition(),
          ProgressBar(
            isExpanded: true,
          ),
          RemainingDuration(),
          FullScreenButton(
            controller: _youTubeCtr,
          )
        ],
      ),
      builder: (ctx, player) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text("Live stream"),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                player,
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: tubeLink,
                            validator: (value) {
                              if (value?.startsWith("https://") == true) {
                                return null;
                              }
                              return "invalid link";
                            },
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: "Paste link here"),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          FilledButton(
                            onPressed: () {
                              final isValid = ((formKey.currentState?..save())
                                      ?.validate()) ??
                                  false;
                              if (isValid) {
                                final videoId =
                                    YoutubePlayer.convertUrlToId(tubeLink.text);
                                if (videoId != null) {
                                  _youTubeCtr.load(videoId);
                                }
                              }
                            },
                            child: const Text("Play"),
                          )
                        ],
                      )),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void unFocus(BuildContext context) {
  final currentFocus = FocusManager.instance.primaryFocus;
  if (currentFocus?.hasPrimaryFocus == true) {
    currentFocus?.unfocus();
  }
}
