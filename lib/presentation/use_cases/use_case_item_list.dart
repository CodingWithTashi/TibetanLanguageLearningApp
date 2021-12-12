import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tibetan_language_learning_app/cubit/audio_cubit.dart';
import 'package:tibetan_language_learning_app/model/alphabet.dart';
import 'package:tibetan_language_learning_app/model/word.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

class UseCaseItemList extends StatefulWidget {
  static const routeName = "use-case-detail-list";
  final UseCaseType type;
  const UseCaseItemList({Key? key, required this.type}) : super(key: key);

  @override
  _UseCaseItemListState createState() => _UseCaseItemListState();
}

class _UseCaseItemListState extends State<UseCaseItemList>
    with TickerProviderStateMixin {
  late List<Word> wordList;
  late List<AnimationController> animatedIconControllerList = [];
  late final AudioCubit cubit;
  late final AudioPlayer player;
  String selectedAudio = '';

  @override
  void initState() {
    player = AudioPlayer();
    cubit = BlocProvider.of<AudioCubit>(context);
    wordList = AppConstant.getWordList(widget.type, this);
    super.initState();
  }

  @override
  void dispose() {
    cubit.destroyAudioPlayer();
    wordList.forEach((element) {
      element.animationController!.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topRight,
        children: [_getBackgroundImage(), _getAnimatedAlphabetListWidget()],
      ),
      floatingActionButton: ApplicationUtil.getFloatingActionButton(context),
    );
  }

  _getBackgroundImage() => Hero(
        tag: 'image',
        child: Container(
          child: Image.asset(
            'assets/images/tree.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            alignment: Alignment.centerRight,
          ),
        ),
      );
  _getAnimatedAlphabetListWidget() => Container(
        constraints: BoxConstraints(maxWidth: 500),
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SingleChildScrollView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          child: AnimationLimiter(
            child: Padding(
              padding: EdgeInsets.only(right: 20, left: 20, top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(
                      milliseconds: ApplicationUtil.ANIMATION_DURATION),
                  childAnimationBuilder: (widget) => SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: widget,
                    ),
                  ),
                  children: _getWordList(),
                ),
              ),
            ),
          ),
        ),
      );
  _getWordList() {
    List<Widget> widgetList = [];
    wordList.forEach((word) {
      widgetList.add(Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: ApplicationUtil.getBoxDecorationOne(context),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: _outerShadow(context),
                      child: Stack(
                        children: <Widget>[
                          Center(
                            child: _playerBoxShadow(context),
                          ),
                          Center(child: BlocBuilder<AudioCubit, AudioState>(
                            builder: (context, state) {
                              if (selectedAudio == word.english) {
                                if (state is AudioPlaying) {
                                  word.animationController!.forward();
                                }
                              }
                              if (state is AudioPause ||
                                  state is AudioStopped) {
                                word.animationController!.reverse();
                              }
                              if (state is AudioLoading) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else {
                                return GestureDetector(
                                  onTap: () async {
                                    selectedAudio = word.english;
                                    cubit.loadAudioByAssetPath(
                                        assetPath: word.assetPath);
                                    if (state is AudioLoaded ||
                                        state is AudioStopped ||
                                        state is AudioPause ||
                                        state is AudioRepeatOff ||
                                        state is AudioRepeatOn) {
                                      cubit.playAudio();
                                    }
                                    if (state is AudioPlaying) {
                                      cubit.pauseAudio();
                                    }
                                    /*if (player.playing) {
                                player.stop();
                              }
                              await player.setAsset(word.assetPath);
                              player.play();*/
                                  },
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle),
                                    child: Center(
                                        child: AnimatedIcon(
                                      progress: word.animationController!,
                                      icon: AnimatedIcons.play_pause,
                                      size: 30,
                                      color:
                                          Theme.of(context).primaryColorLight,
                                    )),
                                  ),
                                );
                              }
                            },
                          )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                word.tibetan,
                style:
                    TextStyle(fontSize: 25, color: Colors.white, height: 1.2),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.english,
                    style: TextStyle(
                        fontSize: 18, color: Colors.white, height: 1.2),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ));
    });
    return widgetList;
  }

  _playerBoxShadow(BuildContext context) => Container(
        margin: EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Theme.of(context).primaryColorLight.withOpacity(0.3),
                  offset: Offset(5, 10),
                  spreadRadius: 3,
                  blurRadius: 10),
              BoxShadow(
                  color: Colors.black,
                  offset: Offset(-3, -4),
                  spreadRadius: -2,
                  blurRadius: 20)
            ]),
      );

  _outerShadow(BuildContext context) => BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Theme.of(context).primaryColorLight.withOpacity(0.3),
              offset: Offset(5, 10),
              spreadRadius: 3,
              blurRadius: 10),
          BoxShadow(
              color: Colors.black,
              offset: Offset(-3, -4),
              spreadRadius: -2,
              blurRadius: 20)
        ],
      );
}
