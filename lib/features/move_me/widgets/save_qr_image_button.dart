import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/core/utils/qr_manager.dart';

class SaveQrImageButton extends StatelessWidget {
  const SaveQrImageButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await QrManager().captureAndSaveQR('https://photocard-kiosk-qr.snaptag.co.kr/ko/SUF');
      },
      child: const Text('저장'),
    );
  }
}
