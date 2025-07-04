import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/bloc.dart';
import '../features/devices/widgets.dart';
import '../features/groups/widgets/widgets.dart';
import '../features/presets/widgets/preset_list_header.dart';
import '../features/settings/bloc/bloc.dart';
import '../services/contacts/phone_contacts.dart';
import '../services/logging/widgets/log_viewer_dialog.dart';
import '../services/notifications/native.dart';
import '../services/runtime_parameters/service.dart';
import '../utils/dialogs.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void signOut(BuildContext context) async {
    final auth = context.read<AuthBloc>();
    final confirm = await ConfirmDialog(context).show(title: 'Sign out?');
    if (confirm) {
      auth.add(const Logout());
    }
  }

  void deleteAccount(BuildContext context) async {
    final auth = context.read<AuthBloc>();

    final confirm = await ConfirmDialog(
      context,
    ).show(title: 'Completely delete account?');
    if (confirm) {
      auth.add(const Logout());
    }
  }

  @override
  Widget build(BuildContext context) {
    final runtimeParameters = context.read<RuntimeParameters>();
    final contactsService = context.read<PhoneContactsService>();
    final nativeNotifications = context.read<NativeNotifications>();
    final appSettings = context.watch<AppSettingsCubit>();
    final auth = context.read<AuthBloc>();
    final currentUser = switch (auth.state) {
      AuthStateSignedIn(currentUser: final user) => user,
      _ => null,
    };

    return ListView(
      children: [
        ListTile(
          title: const Text('ClearRing'),
          subtitle: SelectableText(runtimeParameters.version),
          onLongPress: () async {
            final confirm = await ConfirmDialog(
              context,
            ).show(title: 'Enable developer mode?');
            if (confirm && context.mounted) {
              appSettings.enableDeveloperMode();
            }
          },
        ),
        ListTile(
          leading: const Icon(Icons.group),
          title: const Text('Groups'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push('/settings/groups');
          },
        ),
        ListTile(
          leading: const Icon(Icons.list),
          title: const Text('Profiles'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push('/settings/profiles');
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('Logs'),
          trailing: const Icon(Icons.text_snippet),
          onTap: () {
            LogViewerDialog.show(context);
          },
        ),
        if (!contactsService.hasContactsPermission)
          const ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('Contacts permission is not granted'),
            subtitle: const Text(
              'Please go to the settings and grant permission',
            ),
            onTap: null,
          ),
        if (!nativeNotifications.hasNotificationPolicyAccessPermissions)
          const ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('Notification permission is not granted'),
            subtitle: const Text(
              'Please go to the settings and grant permission',
            ),
          ),
        ListTile(
          trailing: const Icon(Icons.info),
          title: const Text('Licenses'),
          onTap: () {
            showLicensePage(
              applicationName: 'ClearRing',
              applicationVersion: runtimeParameters.version,
              applicationLegalese:
                  'Copyright (C) 2025 Amos JOSHUA\nReleased under the  GNU GENERAL PUBLIC LICENSE Version 3',
              context: context,
            );
          },
        ),
        const Divider(),
        ExpansionTile(
          trailing: const Icon(Icons.devices),
          title: const Text('Devices'),
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300.0),
              child: const DeviceList(),
            ),
          ],
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Logout"),
          subtitle: Text(currentUser?.phoneNumber ?? ''),
          onTap: () => signOut(context),
        ),
        ListTile(
          leading: const Icon(Icons.no_accounts),
          title: const Text(
            'Delete account',
            style: TextStyle(color: Colors.red),
          ),
          onTap: () => deleteAccount(context),
        ),
        if (appSettings.state.appSettings.isDeveloper) ...[
          const Divider(),
          const Text('  Developer'),
          ListTile(title: Text('uid: ${currentUser?.uid}')),
          SwitchListTile(
            title: const Text('Mock webRTC session'),
            value: appSettings.state.appSettings.disableWebRTC,
            onChanged: (value) => appSettings.setDisableWebRTC(value),
          ),
        ],
      ],
    );
  }
}
