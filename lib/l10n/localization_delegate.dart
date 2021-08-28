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
    throw UnimplementedError();
  }

  @override
  String get dateRangeEndLabel => "About title";

  @override
  String get dateRangePickerHelpText => "About title";

  @override
  String dateRangeStartDateSemanticLabel(String formattedDate) {
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  @override
  String formatDecimal(int number) {
    throw UnimplementedError();
  }

  @override
  String formatFullDate(DateTime date) {
    throw UnimplementedError();
  }

  @override
  String formatHour(TimeOfDay timeOfDay, {bool alwaysUse24HourFormat = false}) {
    throw UnimplementedError();
  }

  @override
  String formatMediumDate(DateTime date) {
    throw UnimplementedError();
  }

  @override
  String formatMinute(TimeOfDay timeOfDay) {
    throw UnimplementedError();
  }

  @override
  String formatMonthYear(DateTime date) {
    throw UnimplementedError();
  }

  @override
  String formatShortDate(DateTime date) {
    throw UnimplementedError();
  }

  @override
  String formatShortMonthDay(DateTime date) {
    throw UnimplementedError();
  }

  @override
  String formatTimeOfDay(TimeOfDay timeOfDay,
      {bool alwaysUse24HourFormat = false}) {
    throw UnimplementedError();
  }

  @override
  String formatYear(DateTime date) {
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  @override
  DateTime? parseCompactDate(String? inputString) {
    // TODO: implement parseCompactDate
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
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
    throw UnimplementedError();
  }

  @override
  TimeOfDayFormat timeOfDayFormat({bool alwaysUse24HourFormat = false}) {
    // TODO: implement timeOfDayFormat
    throw UnimplementedError();
  }

  @override
  // TODO: implement timePickerDialHelpText
  String get timePickerDialHelpText => "About title";

  @override
  // TODO: implement timePickerHourLabel
  String get timePickerHourLabel => "About title";

  @override
  // TODO: implement timePickerHourModeAnnouncement
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
}
