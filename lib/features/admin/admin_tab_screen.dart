import 'package:flutter/material.dart';
import 'package:flutter_snaptag_kiosk/features/admin/admin.dart';

class AdminTabScreen extends StatefulWidget {
  const AdminTabScreen({super.key});

  @override
  State<AdminTabScreen> createState() => _AdminTabScreenState();
}

class _AdminTabScreenState extends State<AdminTabScreen> {
  List<Tab> tabs = [Tab(text: '결제 내역'), Tab(text: '프린터 설정')];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: tabs,
          ),
        ),
        body: TabBarView(
          children: [
            PaymentHistoryScreen(),
            PrinterSettingScreen(),
          ],
        ),
      ),
    );
  }
}
