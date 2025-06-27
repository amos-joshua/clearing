import 'package:clearing_client/services/firebase/service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/logging/logging_service.dart';
import 'state.dart';

class DevicesCubit extends Cubit<DevicesState> {
  final FirebaseServiceBase _firebaseRepository;
  final LoggingService _logger;

  DevicesCubit(this._firebaseRepository, this._logger)
    : super(const DevicesState(devices: [], loading: true));

  Future<void> updateIfStale() async {
    final lastUpdated = state.lastUpdated;
    if (lastUpdated == null) {
      list();
    } else {
      final delta = DateTime.now().difference(lastUpdated);
      if (delta.inSeconds > 60) {
        list();
      }
    }
  }

  Future<void> list() async {
    emit(state.copyWith(loading: true));
    try {
      final devices = await _firebaseRepository.getDevices();
       emit(
      state.copyWith(
        loading: false,
        devices: devices,
        lastUpdated: DateTime.now(),
      ),
    );
    } catch (exc, stackTrace) {
      _logger.error('Failed to list devices', exc, stackTrace);
      emit(state.copyWith(loading: false));
    }
  }
}
