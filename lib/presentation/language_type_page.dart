import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tibetan_language_learning_app/cubit/language_cubit.dart';
import 'package:tibetan_language_learning_app/l10n/l10n.dart';
import 'package:tibetan_language_learning_app/presentation/home.dart';
import 'package:tibetan_language_learning_app/util/application_util.dart';
import 'package:tibetan_language_learning_app/util/constant.dart';

import '../servie_locater.dart';

class LanguageTypePage extends StatefulWidget {
  static const routeName = "/language-select";

  const LanguageTypePage({Key? key}) : super(key: key);

  @override
  _LanguageTypePageState createState() => _LanguageTypePageState();
}

class _LanguageTypePageState extends State<LanguageTypePage> {
  late final LanguageCubit cubit;

  @override
  void initState() {
    cubit = BlocProvider.of<LanguageCubit>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  color: Colors.white,
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(40)),
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Center(
                    child: _getUchenUI(),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  color: Theme.of(context).primaryColor,
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(50)),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: _getUmeUI(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _getUmeUI() => Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ཀ་ཁ་ག་ང་',
              style: TextStyle(
                  height: 1.2,
                  color: Colors.black,
                  fontFamily: 'tsutong',
                  fontSize: 55),
            ),
            Text(
              'UMÊ SCRIPT',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              '\"UME script is commonly taught for kids\"',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(
              height: 15,
            ),
            BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, state) {
                if (state is LanguageLoaded) {
                  String lan = state.locale.languageCode;
                  return InkWell(
                    onTap: () {
                      getIt<SharedPreferences>().setString('familyName', AppConstant.TSUTUNG_FAMILY);
                     /* cubit.updateLocale(
                          L10n.all[1], AppConstant.TSUTUNG_FAMILY);*/
                      Navigator.popAndPushNamed(context, HomePage.routeName);
                    },
                    child: Container(
                      width: 250,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      decoration: ApplicationUtil.getBoxDecorationTwo(context),
                      child: Text(
                        'Learn Umê',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      );

  _getUchenUI() => Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ཀ་ཁ་ག་ང་',
              style: TextStyle(
                  color: Colors.white, fontFamily: 'jomolhari', fontSize: 55),
            ),
            Text(
              'UCHEN SCRIPT',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              '\"UCHEN script is commonly used in Prayer & Buddhist teaching\"',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(
              height: 15,
            ),
            BlocBuilder<LanguageCubit, LanguageState>(
              builder: (context, state) {
                if (state is LanguageLoaded) {
                  String lan = state.locale.languageCode;
                  return InkWell(
                    onTap: () {

                      getIt<SharedPreferences>().setString('familyName', AppConstant.JOMAHALI_FAMILY);

                      // cubit.updateLocale(
                      //     L10n.all[1], AppConstant.JOMAHALI_FAMILY);
                      Navigator.popAndPushNamed(context, HomePage.routeName);
                    },
                    child: Container(
                      width: 250,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                      decoration: ApplicationUtil.getBoxDecorationOne(context),
                      child: Text(
                        'Learn Uchen',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      );
}
