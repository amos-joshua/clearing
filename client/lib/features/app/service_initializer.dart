import 'package:clearing_client/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../pages/app_init_failed_page.dart';
import 'bloc.dart';

class ServiceInitializer extends StatelessWidget {
  const ServiceInitializer({
    super.key,
    required this.appServices,
    required this.builder,
    required this.splashScreen,
  });
  final AppServices appServices;
  final Function(BuildContext context) builder;
  final Widget splashScreen;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AppBloc()..add(InitServices(appServices: appServices)),
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          if (state is AppStateInitialized) {
            return builder(context);
          }
          if (state is AppStateInitFailed) {
            return AppInitFailedPage(logger: appServices.logger);
          }
          return splashScreen;
        },
      ),
    );
  }
}
