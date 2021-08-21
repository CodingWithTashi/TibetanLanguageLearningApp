import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
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

  @override
  void initState() {
    selectedPageIndex = alphabetList.indexOf(widget.alphabet);
    controller = PageController(
      initialPage: selectedPageIndex,
    );
    initPageView();
    super.initState();
  }

  @override
  void dispose() {
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
                  height: 350,
                  child: pageView,
                ),
                SizedBox(
                  height: 20,
                ),
                AlphabetAudioControl(
                    pathName: 'assets/audio/',
                    fileName: alphabetList[selectedPageIndex].fileName)
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
          tag: alphabetList[index].alphabetName,
          //center and scrollview is for hero animation
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 50),
                        padding: EdgeInsets.symmetric(vertical: 40),
                        decoration:
                            ApplicationUtil.getBoxDecorationOne(context),
                        child: Text(
                          alphabetList[index].alphabetName,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 120, color: Colors.white),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(left: 55, right: 44),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              size: 40,
                              color: Theme.of(context)
                                  .primaryColorLight
                                  .withAlpha(80),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 40,
                              color: Theme.of(context)
                                  .primaryColorLight
                                  .withAlpha(80),
                            ),
                          ],
                        ),
                      )
                    ],
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

  /* _getPlayerControl() {
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
  }*/
}
