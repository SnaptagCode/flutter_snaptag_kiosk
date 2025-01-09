import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_request.freezed.dart';
part 'payment_request.g.dart';

@freezed
class PaymentRequest with _$PaymentRequest {
  const factory PaymentRequest({
    required String stx,
    required String transactionType,
    required String businessType,

    /// 결제 승인 0200
    /// 결제 취소 0420
    required String messageType,
    required String transactionForm,

    /// 단말기 ID
    /// TEST ID : DPT0TEST03
    /// PROD ID : AT0416146A
    required String terminalId,
    required String companyInfo,
    required String seqNo,
    required String posEntryMode,
    required String uniqueNo,
    required String unencryptedCardNo,
    required String encryptionYn,
    required String swModelNo,
    required String catModelNo,
    required String encryptionInfo,
    required String cardNo,
    required String fs,
    required String installment,
    required String totalAmount,
    required String serviceCharge,
    required String tax,
    required String supplyAmount,
    required String taxFreeAmount,
    required String workingKeyIndex,
    required String password,
    required String originalApprovalNo,
    required String originalApprovalDate,
    required String userInfo,
    required String signYn,
    required String etx,
    required String cr,
  }) = _PaymentRequest;

  factory PaymentRequest.fromJson(Map<String, dynamic> json) => _$PaymentRequestFromJson(json);

  factory PaymentRequest.approval({
    required String totalAmount,
    String tax = '0',
    String supplyAmount = '0',
    bool isTest = false,
  }) {
    return PaymentRequest(
      stx: String.fromCharCode(2),
      transactionType: 'IC',
      businessType: '01',
      messageType: '0200',
      transactionForm: 'N',
      terminalId: isTest ? 'DPT0TEST03' : 'AT0416146A',
      companyInfo: '    ',
      seqNo: '000000000000',
      posEntryMode: ' ',
      uniqueNo: '                    ',
      unencryptedCardNo: '                    ',
      encryptionYn: ' ',
      swModelNo: '                ',
      catModelNo: '                ',
      encryptionInfo: '                                        ',
      cardNo: '                                     ',
      fs: String.fromCharCode(28),
      installment: '00',
      totalAmount: totalAmount.padLeft(12, '0'),
      serviceCharge: '000000000000',
      tax: tax.padLeft(12, '0'),
      supplyAmount: supplyAmount.padLeft(12, '0'),
      taxFreeAmount: '000000000000',
      workingKeyIndex: '  ',
      password: '                ',
      originalApprovalNo: '            ',
      originalApprovalDate: '      ',
      userInfo: ' ' * 163,
      signYn: 'X',
      etx: String.fromCharCode(3),
      cr: String.fromCharCode(13),
    );
  }

  factory PaymentRequest.cancel({
    required String totalAmount,
    String tax = '0',
    String supplyAmount = '0',
    required String originalApprovalNo,
    required String originalApprovalDate,
    bool isTest = false,
  }) {
    return PaymentRequest(
      stx: String.fromCharCode(2),
      transactionType: 'IC',
      businessType: '01',
      messageType: '0420',
      transactionForm: 'N',
      terminalId: isTest ? 'DPT0TEST03' : 'AT0416146A',
      companyInfo: '    ',
      seqNo: '000000000000',
      posEntryMode: ' ',
      uniqueNo: '                    ',
      unencryptedCardNo: '                    ',
      encryptionYn: ' ',
      swModelNo: '                ',
      catModelNo: '                ',
      encryptionInfo: '                                        ',
      cardNo: '                                     ',
      fs: String.fromCharCode(28),
      installment: '00',
      totalAmount: totalAmount.padLeft(12, '0'),
      serviceCharge: '000000000000',
      tax: tax.padLeft(12, '0'),
      supplyAmount: supplyAmount.padLeft(12, '0'),
      taxFreeAmount: '000000000000',
      workingKeyIndex: '  ',
      password: '                ',
      originalApprovalNo: originalApprovalNo.padRight(12, ' '),
      originalApprovalDate: originalApprovalDate.padRight(6, ' '),
      userInfo: ' ' * 163,
      signYn: 'X',
      etx: String.fromCharCode(3),
      cr: String.fromCharCode(13),
    );
  }
}

extension PaymentRequestExtension on PaymentRequest {
  String serialize() {
    final buffer = StringBuffer();

    buffer.write(stx);
    buffer.write(transactionType);
    buffer.write(businessType);
    buffer.write(messageType);
    buffer.write(transactionForm);
    buffer.write(terminalId);
    buffer.write(companyInfo);
    buffer.write(seqNo);
    buffer.write(posEntryMode);
    buffer.write(uniqueNo);
    buffer.write(unencryptedCardNo);
    buffer.write(encryptionYn);
    buffer.write(swModelNo);
    buffer.write(catModelNo);
    buffer.write(encryptionInfo);
    buffer.write(cardNo);
    buffer.write(fs);
    buffer.write(installment);
    buffer.write(totalAmount);
    buffer.write(serviceCharge);
    buffer.write(tax);
    buffer.write(supplyAmount);
    buffer.write(taxFreeAmount);
    buffer.write(workingKeyIndex);
    buffer.write(password);
    buffer.write(originalApprovalNo);
    buffer.write(originalApprovalDate);
    buffer.write(userInfo);
    buffer.write(signYn);
    buffer.write(etx);
    buffer.write(cr);

    final msg = buffer.toString();
    final msgLength = msg.length.toString().padLeft(4, '0');

    return 'AP$msgLength$msg';
  }
}
