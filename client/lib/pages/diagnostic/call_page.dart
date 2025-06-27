import 'package:flutter/material.dart';
import '../../features/call/incoming/widgets/diagnostic/receive_call_form.dart';
import '../../features/call/outgoing/widgets/diagnostic/start_call_form.dart';



class DiagnosticCallPage extends StatefulWidget {
  const DiagnosticCallPage({super.key});


  @override
  State<DiagnosticCallPage> createState() => _DiagnosticCallPageState();
}

class _DiagnosticCallPageState extends State<DiagnosticCallPage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = const <Widget>[
    DiagnosticStartCallForm(),
    DiagnosticReceiveCallForm()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: SizedBox(width: 800,child: _widgetOptions[_selectedIndex])),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.call_made),
            label: 'Outgoing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call_received),
            label: 'Incoming',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
