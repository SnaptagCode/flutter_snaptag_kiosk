import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/lib.dart';

class DialogTestWidget extends StatelessWidget {
  const DialogTestWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => DialogHelper.showErrorDialog(context),
          style: context.dialogButtonStyle,
          child: Text('Show Error Dialog'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => DialogHelper.showPurchaseFailedDialog(context),
          style: context.dialogButtonStyle,
          child: Text('Show Purchase Failed Dialog'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => DialogHelper.showPrintErrorDialog(
            context,
            onButtonPressed: () {
              HomeRouteData().go(context);
            },
          ),
          style: context.dialogButtonStyle,
          child: Text('Show Print Error Dialog'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => DialogHelper.showPrintCompleteDialog(
            context,
            onButtonPressed: () {
              HomeRouteData().go(context);
            },
          ),
          style: context.dialogButtonStyle,
          child: Text('Show Print Complete Dialog'),
        ),
      ],
    );
  }
}
