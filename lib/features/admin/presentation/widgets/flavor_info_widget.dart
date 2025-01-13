import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class FlavorInfoWidget extends StatelessWidget {
  const FlavorInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Flavor Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            _buildInfoRow('Current Flavor', F.name.toUpperCase()),
            _buildInfoRow('App Title', F.title),
            _buildInfoRow('Admin URL', F.adminBaseUrl),
            _buildInfoRow('Kiosk URL', F.kioskBaseUrl),
            _buildInfoRow('QR Code Prefix', F.qrCodePrefix),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                color: F.appFlavor == Flavor.dev ? Colors.blue : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
