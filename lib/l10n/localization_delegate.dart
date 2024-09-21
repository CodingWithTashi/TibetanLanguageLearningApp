import 'package:flutter/material.dart';

class MaterialLocalizationTbDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == "bo";
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    return MaterialLocalizationTb();
  }

  @override
  bool shouldReload(
      covariant LocalizationsDelegate<MaterialLocalizations> old) {
    return false;
  }
}

class MaterialLocalizationTb extends MaterialLocalizations {
  @override
  String aboutListTileTitle(String applicationName) {
    return "About title";
  }

  @override
  String get alertDialogLabel => "About title";

  @override
  String get anteMeridiemAbbreviation => "About title";

  @override
  String get backButtonTooltip => "About title";

  @override
  String get calendarModeButtonLabel => "About title";

  @override
  String get cancelButtonLabel => "About title";

  @override
  String get closeButtonLabel => "About title";

  @override
  String get closeButtonTooltip => "About title";

  @override
  String get continueButtonLabel => "About title";

  @override
  String get copyButtonLabel => "About title";

  @override
  String get cutButtonLabel => "About title";

  @override
  String get dateHelpText => "About title";

  @override
  String get dateInputLabel => "About title";

  @override
  String get dateOutOfRangeLabel => "About title";

  @override
  String get datePickerHelpText => "About title";

  @override
  String dateRangeEndDateSemanticLabel(String formattedDate) {
    return '';
  }

  @override
  String get dateRangeEndLabel => "About title";

  @override
  String get dateRangePickerHelpText => "About title";

  @override
  String dateRangeStartDateSemanticLabel(String formattedDate) {
    return '';
  }

  @override
  String get dateRangeStartLabel => "About title";

  @override
  String get dateSeparator => "About title";

  @override
  String get deleteButtonTooltip => "About title";

  @override
  String get dialModeButtonLabel => "About title";

  @override
  String get dialogLabel => "About title";

  @override
  String get drawerLabel => "About title";

  @override
  int get firstDayOfWeekIndex => 4;

  @override
  String get firstPageTooltip => "About title";

  @override
  String formatCompactDate(DateTime date) {
    return '';
  }

  @override
  String formatDecimal(int number) {
    return '';
  }

  @override
  String formatFullDate(DateTime date) {
    return '';
  }

  @override
  String formatHour(TimeOfDay timeOfDay, {bool alwaysUse24HourFormat = false}) {
    return '';
  }

  @override
  String formatMediumDate(DateTime date) {
    return '';
  }

  @override
  String formatMinute(TimeOfDay timeOfDay) {
    return '';
  }

  @override
  String formatMonthYear(DateTime date) {
    return '';
  }

  @override
  String formatShortDate(DateTime date) {
    return '';
  }

  @override
  String formatShortMonthDay(DateTime date) {
    return '';
  }

  @override
  String formatTimeOfDay(TimeOfDay timeOfDay,
      {bool alwaysUse24HourFormat = false}) {
    return '';
  }

  @override
  String formatYear(DateTime date) {
    return '';
  }

  @override
  // ODO: implement hideAccountsLabel
  String get hideAccountsLabel => "About title";

  @override
  // TODO: implement inputDateModeButtonLabel
  String get inputDateModeButtonLabel => "About title";

  @override
  // TODO: implement inputTimeModeButtonLabel
  String get inputTimeModeButtonLabel => "About title";

  @override
  // TODO: implement invalidDateFormatLabel
  String get invalidDateFormatLabel => "About title";

  @override
  // TODO: implement invalidDateRangeLabel
  String get invalidDateRangeLabel => "About title";

  @override
  // TODO: implement invalidTimeLabel
  String get invalidTimeLabel => "About title";

  @override
  // TODO: implement lastPageTooltip
  String get lastPageTooltip => "About title";

  @override
  String licensesPackageDetailText(int licenseCount) {
    // TODO: implement licensesPackageDetailText
    return '';
  }

  @override
  // TODO: implement licensesPageTitle
  String get licensesPageTitle => "About title";

  @override
  // TODO: implement modalBarrierDismissLabel
  String get modalBarrierDismissLabel => "About title";

  @override
  // TODO: implement moreButtonTooltip
  String get moreButtonTooltip => "About title";

  @override
  // TODO: implement narrowWeekdays
  List<String> get narrowWeekdays => [];

  @override
  // TODO: implement nextMonthTooltip
  String get nextMonthTooltip => "About title";

  @override
  // TODO: implement nextPageTooltip
  String get nextPageTooltip => "About title";

  @override
  // TODO: implement okButtonLabel
  String get okButtonLabel => "About title";

  @override
  // TODO: implement openAppDrawerTooltip
  String get openAppDrawerTooltip => "About title";

  @override
  String pageRowsInfoTitle(
      int firstRow, int lastRow, int rowCount, bool rowCountIsApproximate) {
    // TODO: implement pageRowsInfoTitle
    return '';
  }

  @override
  DateTime? parseCompactDate(String? inputString) {
    // TODO: implement parseCompactDate
    return DateTime.now();
  }

  @override
  // TODO: implement pasteButtonLabel
  String get pasteButtonLabel => "About title";

  @override
  // TODO: implement popupMenuLabel
  String get popupMenuLabel => "About title";

  @override
  // TODO: implement postMeridiemAbbreviation
  String get postMeridiemAbbreviation => "About title";

  @override
  // TODO: implement previousMonthTooltip
  String get previousMonthTooltip => "About title";

  @override
  // TODO: implement previousPageTooltip
  String get previousPageTooltip => "About title";

  @override
  // TODO: implement refreshIndicatorSemanticLabel
  String get refreshIndicatorSemanticLabel => "About title";

  @override
  String remainingTextFieldCharacterCount(int remaining) {
    // TODO: implement remainingTextFieldCharacterCount
    return '';
  }

  @override
  // TODO: implement reorderItemDown
  String get reorderItemDown => "About title";

  @override
  // TODO: implement reorderItemLeft
  String get reorderItemLeft => "About title";

  @override
  // TODO: implement reorderItemRight
  String get reorderItemRight => "About title";

  @override
  // TODO: implement reorderItemToEnd
  String get reorderItemToEnd => "About title";

  @override
  // TODO: implement reorderItemToStart
  String get reorderItemToStart => "About title";

  @override
  // TODO: implement reorderItemUp
  String get reorderItemUp => "About title";

  @override
  // TODO: implement rowsPerPageTitle
  String get rowsPerPageTitle => "About title";

  @override
  // TODO: implement saveButtonLabel
  String get saveButtonLabel => "About title";

  @override
  // TODO: implement scriptCategory
  ScriptCategory get scriptCategory => ScriptCategory.dense;

  @override
  // TODO: implement searchFieldLabel
  String get searchFieldLabel => "About title";

  @override
  // TODO: implement selectAllButtonLabel
  String get selectAllButtonLabel => "About title";

  @override
  // TODO: implement selectYearSemanticsLabel
  String get selectYearSemanticsLabel => "About title";

  @override
  String selectedRowCountTitle(int selectedRowCount) {
    // TODO: implement selectedRowCountTitle
    return '';
  }

  @override
  // TODO: implement showAccountsLabel
  String get showAccountsLabel => "About title";

  @override
  // TODO: implement showMenuTooltip
  String get showMenuTooltip => "About title";

  @override
  // TODO: implement signedInLabel
  String get signedInLabel => "About title";

  @override
  String tabLabel({required int tabIndex, required int tabCount}) {
    // TODO: implement tabLabel
    return '';
  }

  @override
  TimeOfDayFormat timeOfDayFormat({bool alwaysUse24HourFormat = false}) {
    return TimeOfDayFormat.HH_dot_mm;
  }

  @override
  String get timePickerDialHelpText => "About title";

  @override
  String get timePickerHourLabel => "About title";

  @override
  String get timePickerHourModeAnnouncement => "About title";

  @override
  // TODO: implement timePickerInputHelpText
  String get timePickerInputHelpText => "About title";

  @override
  // TODO: implement timePickerMinuteLabel
  String get timePickerMinuteLabel => "About title";

  @override
  // TODO: implement timePickerMinuteModeAnnouncement
  String get timePickerMinuteModeAnnouncement => "About title";

  @override
  // TODO: implement unspecifiedDate
  String get unspecifiedDate => "About title";

  @override
  String get unspecifiedDateRange => "About title";

  @override
  String get viewLicensesButtonLabel => "About title";

  @override
  String get keyboardKeyAlt => '';

  @override
  // TODO: implement keyboardKeyAltGraph
  String get keyboardKeyAltGraph => '';

  @override
  // TODO: implement keyboardKeyBackspace
  String get keyboardKeyBackspace => '';

  @override
  // TODO: implement keyboardKeyCapsLock
  String get keyboardKeyCapsLock => '';

  @override
  // TODO: implement keyboardKeyChannelDown
  String get keyboardKeyChannelDown => '';

  @override
  // TODO: implement keyboardKeyChannelUp
  String get keyboardKeyChannelUp => '';

  @override
  // TODO: implement keyboardKeyControl
  String get keyboardKeyControl => '';

  @override
  // TODO: implement keyboardKeyDelete
  String get keyboardKeyDelete => '';

  @override
  // TODO: implement keyboardKeyEisu
  String get keyboardKeyEisu => '';

  @override
  // TODO: implement keyboardKeyEject
  String get keyboardKeyEject => '';

  @override
  // TODO: implement keyboardKeyEnd
  String get keyboardKeyEnd => '';

  @override
  // TODO: implement keyboardKeyEscape
  String get keyboardKeyEscape => '';

  @override
  // TODO: implement keyboardKeyFn
  String get keyboardKeyFn => '';

  @override
  // TODO: implement keyboardKeyHangulMode
  String get keyboardKeyHangulMode => '';

  @override
  // TODO: implement keyboardKeyHanjaMode
  String get keyboardKeyHanjaMode => '';

  @override
  // TODO: implement keyboardKeyHankaku
  String get keyboardKeyHankaku => '';

  @override
  // TODO: implement keyboardKeyHiragana
  String get keyboardKeyHiragana => '';

  @override
  // TODO: implement keyboardKeyHiraganaKatakana
  String get keyboardKeyHiraganaKatakana => '';

  @override
  // TODO: implement keyboardKeyHome
  String get keyboardKeyHome => '';

  @override
  // TODO: implement keyboardKeyInsert
  String get keyboardKeyInsert => '';

  @override
  // TODO: implement keyboardKeyKanaMode
  String get keyboardKeyKanaMode => '';

  @override
  // TODO: implement keyboardKeyKanjiMode
  String get keyboardKeyKanjiMode => '';

  @override
  // TODO: implement keyboardKeyKatakana
  String get keyboardKeyKatakana => '';

  @override
  // TODO: implement keyboardKeyMeta
  String get keyboardKeyMeta => '';

  @override
  // TODO: implement keyboardKeyMetaMacOs
  String get keyboardKeyMetaMacOs => '';

  @override
  // TODO: implement keyboardKeyMetaWindows
  String get keyboardKeyMetaWindows => '';

  @override
  // TODO: implement keyboardKeyNumLock
  String get keyboardKeyNumLock => '';

  @override
  // TODO: implement keyboardKeyNumpad0
  String get keyboardKeyNumpad0 => '';

  @override
  // TODO: implement keyboardKeyNumpad1
  String get keyboardKeyNumpad1 => '';

  @override
  // TODO: implement keyboardKeyNumpad2
  String get keyboardKeyNumpad2 => '';

  @override
  // TODO: implement keyboardKeyNumpad3
  String get keyboardKeyNumpad3 => '';

  @override
  // TODO: implement keyboardKeyNumpad4
  String get keyboardKeyNumpad4 => '';

  @override
  // TODO: implement keyboardKeyNumpad5
  String get keyboardKeyNumpad5 => '';

  @override
  // TODO: implement keyboardKeyNumpad6
  String get keyboardKeyNumpad6 => '';

  @override
  // TODO: implement keyboardKeyNumpad7
  String get keyboardKeyNumpad7 => '';

  @override
  // TODO: implement keyboardKeyNumpad8
  String get keyboardKeyNumpad8 => '';

  @override
  // TODO: implement keyboardKeyNumpad9
  String get keyboardKeyNumpad9 => '';

  @override
  // TODO: implement keyboardKeyNumpadAdd
  String get keyboardKeyNumpadAdd => '';

  @override
  // TODO: implement keyboardKeyNumpadComma
  String get keyboardKeyNumpadComma => '';

  @override
  // TODO: implement keyboardKeyNumpadDecimal
  String get keyboardKeyNumpadDecimal => '';

  @override
  // TODO: implement keyboardKeyNumpadDivide
  String get keyboardKeyNumpadDivide => '';

  @override
  // TODO: implement keyboardKeyNumpadEnter
  String get keyboardKeyNumpadEnter => '';

  @override
  // TODO: implement keyboardKeyNumpadEqual
  String get keyboardKeyNumpadEqual => '';

  @override
  // TODO: implement keyboardKeyNumpadMultiply
  String get keyboardKeyNumpadMultiply => '';

  @override
  // TODO: implement keyboardKeyNumpadParenLeft
  String get keyboardKeyNumpadParenLeft => '';

  @override
  // TODO: implement keyboardKeyNumpadParenRight
  String get keyboardKeyNumpadParenRight => '';

  @override
  // TODO: implement keyboardKeyNumpadSubtract
  String get keyboardKeyNumpadSubtract => '';

  @override
  // TODO: implement keyboardKeyPageDown
  String get keyboardKeyPageDown => '';

  @override
  // TODO: implement keyboardKeyPageUp
  String get keyboardKeyPageUp => '';

  @override
  // TODO: implement keyboardKeyPower
  String get keyboardKeyPower => '';

  @override
  // TODO: implement keyboardKeyPowerOff
  String get keyboardKeyPowerOff => '';

  @override
  // TODO: implement keyboardKeyPrintScreen
  String get keyboardKeyPrintScreen => '';

  @override
  // TODO: implement keyboardKeyRomaji
  String get keyboardKeyRomaji => '';

  @override
  // TODO: implement keyboardKeyScrollLock
  String get keyboardKeyScrollLock => '';

  @override
  // TODO: implement keyboardKeySelect
  String get keyboardKeySelect => '';

  @override
  // TODO: implement keyboardKeySpace
  String get keyboardKeySpace => '';

  @override
  // TODO: implement keyboardKeyZenkaku
  String get keyboardKeyZenkaku => '';

  @override
  // TODO: implement keyboardKeyZenkakuHankaku
  String get keyboardKeyZenkakuHankaku => '';

  @override
  // TODO: implement bottomSheetLabel
  String get bottomSheetLabel => throw UnimplementedError();

  @override
  // TODO: implement clearButtonTooltip
  String get clearButtonTooltip => throw UnimplementedError();

  @override
  // TODO: implement currentDateLabel
  String get currentDateLabel => throw UnimplementedError();

  @override
  // TODO: implement keyboardKeyShift
  String get keyboardKeyShift => throw UnimplementedError();

  @override
  // TODO: implement lookUpButtonLabel
  String get lookUpButtonLabel => throw UnimplementedError();

  @override
  // TODO: implement menuBarMenuLabel
  String get menuBarMenuLabel => throw UnimplementedError();

  @override
  // TODO: implement menuDismissLabel
  String get menuDismissLabel => throw UnimplementedError();

  @override
  // TODO: implement scanTextButtonLabel
  String get scanTextButtonLabel => throw UnimplementedError();

  @override
  // TODO: implement scrimLabel
  String get scrimLabel => throw UnimplementedError();

  @override
  String scrimOnTapHint(String modalRouteContentName) {
    // TODO: implement scrimOnTapHint
    throw UnimplementedError();
  }

  @override
  // TODO: implement searchWebButtonLabel
  String get searchWebButtonLabel => throw UnimplementedError();

  @override
  // TODO: implement selectedDateLabel
  String get selectedDateLabel => throw UnimplementedError();

  @override
  // TODO: implement shareButtonLabel
  String get shareButtonLabel => throw UnimplementedError();
}
