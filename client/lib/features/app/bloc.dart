import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../services/app_services.dart';

part 'bloc.freezed.dart';

@freezed
sealed class AppState with _$AppState {
  const AppState._(); // Private constructor for base class fields
  const factory AppState.initializing() = AppStateInitializing;
  const factory AppState.initialized({required AppServices appServices}) =
      AppStateInitialized;
  const factory AppState.initFailed() = AppStateInitFailed;
}

@freezed
sealed class AppEvent with _$AppEvent {
  const factory AppEvent.initServices({required AppServices appServices}) =
      InitServices;
}

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState.initializing()) {
    on<InitServices>(_onInitServices);
  }

  void _onInitServices(InitServices event, Emitter<AppState> emit) async {
    final success = await event.appServices.init();
    if (success) {
      emit(AppStateInitialized(appServices: event.appServices));
    } else {
      emit(const AppStateInitFailed());
    }
  }
}
