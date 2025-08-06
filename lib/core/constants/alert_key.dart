enum ErrorKey {
  printerRibonEmpty("Printer_Ribon_Empty"),
  printerFilmEmpty("Printer_Film_Empty"),
  printerCardEmpty("Printer_Card_Empty"),
  printerEjectFail("Printer_Eject_Fail"),
  printerReadyFail("Printer_Ready_Fail"),
  printerPrintFail("Printer_Print_Fail"),
  severError("Sever_Error");

  final String key;
  const ErrorKey(this.key);
}

enum WarningKey {
  printerRibonR20("Printer_Ribon_R20"),
  printerRibonR10("Printer_Ribon_R10"),
  printerRibonR5("Printer_Ribon_R5"),
  printerFilmR20("Printer_Film_R20"),
  printerFilmR10("Printer_Film_R10"),
  printerFilmR5("Printer_Film_R5");

  final String key;
  const WarningKey(this.key);
}

enum InfoKey {
  cardPrintModeSwitchDuplex("Card_PrintMode_Switch_Duplex"),
  cardPrintModeSwitchSingle("Card_PrintMode_Switch_Single"),
  inspectionStart("Inspection_Start"),
  inspectionEnd("Inspection_End");

  final String key;
  const InfoKey(this.key);
}
