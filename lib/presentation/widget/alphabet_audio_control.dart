import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AlphabetAudioControl extends StatelessWidget {
  final IconData icon;
  final Function onClick;

  AlphabetAudioControl({
    Key? key,
    required this.icon,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
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
      ),
      child: Stack(
        children: <Widget>[
          Center(
            child: Container(
              margin: EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Theme.of(context)
                            .primaryColorLight
                            .withOpacity(0.3),
                        offset: Offset(5, 10),
                        spreadRadius: 3,
                        blurRadius: 10),
                    BoxShadow(
                        color: Colors.black,
                        offset: Offset(-3, -4),
                        spreadRadius: -2,
                        blurRadius: 20)
                  ]),
            ),
          ),
          Center(
            child: InkWell(
              onTap: () => onClick(),
              child: Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle),
                child: Center(
                    child: Icon(
                  icon,
                  size: 30,
                  color: Theme.of(context).primaryColorLight,
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
