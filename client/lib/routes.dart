import 'package:clearing_client/features/call/bloc/widgets.dart';
import 'package:clearing_client/features/groups/widgets/widgets.dart';
import 'package:clearing_client/features/presets/widgets/preset_list_header.dart';
import 'package:clearing_client/pages/groups_list_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'features/call/incoming/bloc/incoming_call_bloc.dart';
import 'features/call/incoming/widgets/call_starter.dart';
import 'features/call/model/call.dart';
import 'features/call/outgoing/bloc/outgoing_call_bloc.dart';
import 'features/groups/bloc/cubit.dart';
import 'features/presets/bloc/cubit.dart';
import 'features/settings/widgets/settings_scaffold.dart';
import 'pages/group_detail_page.dart';
import 'pages/incoming_call_page.dart';
import 'pages/outgoing_call_page.dart';
import 'pages/preset_detail_page.dart';
import 'pages/scaffolds/root_scaffold.dart';
import 'pages/settings_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNavigatorKey',
);
final _homeNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'homeNavigatorStateKey',
);
final _callsNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'callsNavigatorStateKey',
);

// GoRouter configuration
final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  routes: [
    GoRoute(
      path: '/settings',
      builder: (context, state) =>
          const SettingsScaffold(title: 'Settings', body: SettingsPage()),
      routes: [
        GoRoute(
          path: 'groups',
          builder: (context, state) => const SettingsScaffold(
            title: 'Groups',
            body: GroupsListWithAddButton(),
          ),
        ),
        GoRoute(
          path: 'profiles',
          builder: (context, state) => const SettingsScaffold(
            title: 'Profiles',
            body: PresetsListWithAddButton(),
          ),
        ),
      ],
    ),
    StatefulShellRoute(
      builder: (context, state, navigationShell) {
        return CallStarter(
          child: RootScaffold(navigationShell: navigationShell),
        );
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/',
              builder: (context, state) => const GroupsListHomePage(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'group_detail',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final groupCubit = state.extra as GroupCubit;
                    return BlocProvider.value(
                      value: groupCubit,
                      child: const GroupDetailPage(),
                    );
                  },
                ),
                GoRoute(
                  path: 'preset_detail',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final presetCubit = state.extra as PresetCubit;
                    return BlocProvider.value(
                      value: presetCubit,
                      child: const PresetDetailPage(),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _callsNavigatorKey,
          routes: <RouteBase>[
            GoRoute(
              path: '/calls',
              builder: (context, state) => const CallsList(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'outgoing_call',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (BuildContext context, GoRouterState state) {
                    final args =
                        state.extra as ({Call call, OutgoingCallBloc callBloc});
                    return Material(
                      child: OutgoingCallPage(
                        call: args.call,
                        callBloc: args.callBloc,
                        inScaffold: false,
                      ),
                    );
                  },
                ),
                GoRoute(
                  path: 'incoming_call',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (BuildContext context, GoRouterState state) {
                    final args =
                        state.extra as ({Call call, IncomingCallBloc callBloc});
                    return Material(
                      child: IncomingCallPage(
                        call: args.call,
                        callBloc: args.callBloc,
                        inScaffold: false,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
      navigatorContainerBuilder: (context, navigationShell, children) {
        return children[navigationShell.currentIndex];
      },
    ),
  ],
);
