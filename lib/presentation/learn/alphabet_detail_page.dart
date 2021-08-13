import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tibetan_language_learning_app/presentation/widget/alphabet_audio_control.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class AlphabetDetailPage extends StatefulWidget {
  final Alphabet alphabet;
  static const routeName = "/alphabet-detail-page";
  const AlphabetDetailPage({Key? key, required this.alphabet})
      : super(key: key);

  @override
  _AlphabetDetailPageState createState() => _AlphabetDetailPageState();
}

class _AlphabetDetailPageState extends State<AlphabetDetailPage> {
  var controller;
  var selectedPageIndex = 0;
  var pageView;
  List<Alphabet> alphabetList = AppConstant.alphabetList;
  late AudioPlayer _audioPlayer;
  var playPauseIcon = Icons.play_arrow;

  @override
  void initState() {
    _audioPlayer = AudioPlayer();
    selectedPageIndex = alphabetList.indexOf(widget.alphabet);
    controller = PageController(
      initialPage: selectedPageIndex,
    );
    _audioPlayer.playerStateStream.listen((event) {
      print('Listening');
      if (event.playing) {
        print(event.processingState);
      } else {
        print("stop");
      }
    });
    initPageView();
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();

    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Container(
        child: Center(
          child: SingleChildScrollView(
            /*physics:
                BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),*/
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 300,
                  child: pageView,
                ),
                SizedBox(
                  height: 20,
                ),
                _getPlayerControl()
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ApplicationUtil.getFloatingActionButton(context),
    );
  }

  void initPageView() {
    pageView = PageView.builder(
      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: alphabetList.length,
      controller: controller,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Hero(
          tag: alphabetList[index],
          //center and scrollview is for hero animation
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 100, vertical: 40),
                    decoration: ApplicationUtil.getBoxDecorationOne(context),
                    child: Text(
                      alphabetList[index].alphabetName,
                      style: TextStyle(fontSize: 120, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      onPageChanged: (index) => setState(() => selectedPageIndex = index),
    );
  }

  _getPlayerControl() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: AlphabetAudioControl(
            icon: Icons.repeat,
            onClick: () {
              print('clicked repeat');
              _audioPlayer.setLoopMode(LoopMode.one);
            },
          ),
        ),
        Flexible(
          child: SizedBox(
            width: 20,
          ),
        ),
        Flexible(
          child: AlphabetAudioControl(
            icon: playPauseIcon,
            onClick: () async {
              if (!_audioPlayer.playing) {
                await _audioPlayer.setAsset(ApplicationUtil.getAudioAssetPath(
                    audioName: alphabetList[selectedPageIndex].fileName));
                playPauseIcon = Icons.pause;
                _audioPlayer.play();
              } else {
                playPauseIcon = Icons.play_arrow;
                _audioPlayer.pause();
              }
              setState(() {});
            },
          ),
        ),
        SizedBox(
          width: 20,
        ),
        AlphabetAudioControl(
          icon: Icons.stop,
          onClick: () {
            if (_audioPlayer.playing) {
              _audioPlayer.stop();
            }
          },
        ),
      ],
    );
  }
}
