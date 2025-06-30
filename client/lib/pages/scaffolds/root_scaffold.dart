import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/presets/widgets/active_preset_widgets.dart';
import '../../services/active_call/active_call.dart';
import '../../utils/dialogs.dart';
import '../../utils/widgets/settings_icon.dart';

class RootScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const RootScaffold({required this.navigationShell, super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  //late final StreamSubscription? incomingCallSubscription;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("ClearRing"),
          actions: const [SettingsIcon()],
        ),
        body: widget.navigationShell,
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(label: 'Status', icon: Icon(Icons.home)),
            BottomNavigationBarItem(label: 'Calls', icon: Icon(Icons.call)),
          ],
          currentIndex: widget.navigationShell.currentIndex,
          onTap: (index) => widget.navigationShell.goBranch(index),
        ),
        floatingActionButton: widget.navigationShell.currentIndex == 0
            ? const FloatingActionButton(
                onPressed: null,
                child: PresetOverridePopupButton(),
              )
            : widget.navigationShell.currentIndex == 1
            ? FloatingActionButton(
                onPressed: () async {
                  final context = this.context;
                  final activeCallService = context.read<ActiveCallService>();
                  final contact = await SelectContactsDialog(
                    context,
                  ).show([], singleChoice: true);
                  if (contact == null || contact.isEmpty || !context.mounted) {
                    return;
                  }
                  final call = await StartCallDialog(
                    context,
                  ).showForContact(contact.first);
                  if (call == null || !context.mounted) {
                    return;
                  }
                  
                  activeCallService.requestOutgoingCallStart(call);
                },
                child: const Icon(Icons.call),
              )
            : null,
      ),
    );
  }
}
