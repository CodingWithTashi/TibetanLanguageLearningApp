import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tibetan_language_learning_app/cubit/language_cubit.dart';
import 'package:tibetan_language_learning_app/l10n/l10n.dart';

class LanguageWidget extends StatefulWidget {
  const LanguageWidget({Key? key}) : super(key: key);

  @override
  _LanguageWidgetState createState() => _LanguageWidgetState();
}

class _LanguageWidgetState extends State<LanguageWidget> {
  late final LanguageCubit cubit;

  @override
  void initState() {
    cubit = BlocProvider.of<LanguageCubit>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('En'),
        BlocBuilder<LanguageCubit, LanguageState>(
          builder: (context, state) {
            if (state is LanguageLoaded) {
              return Switch(
                value: state.locale.languageCode == "bo",
                onChanged: (value) {
                  if (value) {
                    cubit.updateLocale(L10n.all[1]);
                  } else {
                    cubit.updateLocale(L10n.all[0]);
                  }
                },
              );
            }
            return SizedBox(
                width: 20, height: 20, child: CircularProgressIndicator());
          },
        ),
        Text('Tb'),
      ],
    );
  }
}
