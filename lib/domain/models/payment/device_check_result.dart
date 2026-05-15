class DeviceCheckResult {
  final String? res;
  final String? errcode;
  final String? reader;
  final String? serialno;
  final String? swversion;
  final String? keyyn;

  const DeviceCheckResult({
    this.res,
    this.errcode,
    this.reader,
    this.serialno,
    this.swversion,
    this.keyyn,
  });

  @override
  String toString() =>
      'DeviceCheckResult(res: $res, errcode: $errcode, reader: $reader, serialno: $serialno)';
}
