import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:tibetan_language_learning_app/cubit/audio_cubit.dart';

class AlphabetAudioControl extends StatefulWidget {
  final String filePath;
  AlphabetAudioControl({Key? key, required this.filePath}) : super(key: key);

  @override
  _AlphabetAudioControlState createState() => _AlphabetAudioControlState();
}

class _AlphabetAudioControlState extends State<AlphabetAudioControl>
    with SingleTickerProviderStateMixin {
  late AnimationController animatedIconController;
  late AudioPlayer audioPlayer;
  @override
  void initState() {
    audioPlayer = AudioPlayer();
    animatedIconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
      reverseDuration: Duration(milliseconds: 400),
    );
    super.initState();
  }

  @override
  void dispose() {
    animatedIconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle),
                      child: Center(
                          child: Icon(
                        Icons.repeat,
                        size: 30,
                        color: Theme.of(context).primaryColorLight,
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 15,
        ),
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
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle),
                      child: Center(
                          child: AnimatedIcon(
                        progress: animatedIconController,
                        icon: AnimatedIcons.play_pause,
                        size: 30,
                        color: Theme.of(context).primaryColorLight,
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 15,
        ),
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
                Center(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle),
                      child: Center(
                          child: Icon(
                        Icons.stop,
                        size: 30,
                        color: Theme.of(context).primaryColorLight,
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
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
