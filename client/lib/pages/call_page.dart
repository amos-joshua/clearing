import 'package:flutter/material.dart';
import '../features/call/incoming/widgets/diagnostic/incoming_call_staging_widget.dart';
import '../features/call/outgoing/widgets/diagnostic/outgoing_call_staging_widget.dart';


class CallPage extends StatefulWidget {
  const CallPage({super.key, required this.title});

  final String title;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const OutgoingCallStagingWidget(),
    const IncomingCallStagingWidget(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
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
