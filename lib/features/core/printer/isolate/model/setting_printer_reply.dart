class SettingPrinterReply {
  bool isReady;
  String errorMsg = '';

  SettingPrinterReply({
    errorMsg = '',
    required this.isReady,
  });
}
