class ConnectReply {
  bool isConnected;
  String errorMsg = '';

  ConnectReply({
    errorMsg = '',
    required this.isConnected,
  });
}
