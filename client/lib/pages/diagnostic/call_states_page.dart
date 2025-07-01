import 'package:clearing_client/features/call/model/call.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/call/call_gateway_impl.dart';
import '../../features/call/incoming/bloc/incoming_call_bloc.dart';
import '../../features/call/outgoing/bloc/outgoing_call_bloc.dart';
import '../../features/call/outgoing/widgets/diagnostic/outgoing_call_staging_widget.dart';
import '../../features/call/incoming/widgets/diagnostic/incoming_call_staging_widget.dart';
import '../../services/logging/logging_service.dart';
import '../../services/logging/widgets/log_viewer_button.dart';
import '../../services/notifications/native.dart';
import '../../services/storage/database.dart';

class DiagnosticsCallStatesPage extends StatefulWidget {
  const DiagnosticsCallStatesPage({super.key});

  @override
  State<DiagnosticsCallStatesPage> createState() =>
      _DiagnosticsCallStatesPageState();
}

class _DiagnosticsCallStatesPageState extends State<DiagnosticsCallStatesPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call States'),
        actions: const [LogViewerButton()],
      ),
      body: Center(
        child: SizedBox(
          width: 800,
          child: _selectedIndex == 0 ? outgoingCallPage : incomingCallPage,
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }

  Widget get outgoingCallPage {
    final call = Call(callUuid: 'test-uuid');
    return OutgoingCallBloc.provider(
      call: call,
      database: context.read<Database>(),
      logger: context.read<LoggingService>(),
      webrtcSession: null,
      callBloc: OutgoingCallBloc(
        database: context.read<Database>(),
        call,
        CallGatewayScripted([]),
        logger: context.read<LoggingService>(),
        webrtcSession: null,
      ),
      child: const OutgoingCallStagingWidget(),
    );
  }

  Widget get incomingCallPage {
    final call = Call(callUuid: 'test-uuid');
    return IncomingCallBloc.provider(
      call: call,
      database: context.read<Database>(),
      logger: context.read<LoggingService>(),
      webrtcSession: null,
      callBloc: IncomingCallBloc(
        CallGatewayScripted([]),
        call,
        logger: context.read<LoggingService>(),
        webrtcSession: null,
        database: context.read<Database>(),
        nativeNotifications: context.read<NativeNotifications>(),
      ),
      child: const IncomingCallStagingWidget(),
    );
  }

  Widget get bottomNavigationBar => BottomNavigationBar(
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.call_made), label: 'Outgoing'),
      BottomNavigationBarItem(
        icon: Icon(Icons.call_received),
        label: 'Incoming',
      ),
    ],
    currentIndex: _selectedIndex,
    onTap: _onItemTapped,
  );
}
