import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/storage/database.dart';
import '../../../services/storage/db_events.dart';
import 'state.dart';


class CallsCubit extends Cubit<CallsState> {
  final Database database;
  StreamSubscription<DBEvent>? _eventSubscription;

  CallsCubit({required this.database}) : super(const CallsState()) {
    _eventSubscription = database.events.listen(_onDBEvent);
  }

  void _onDBEvent(DBEvent event) {
    if (event is DBEventCallModified) {
      list();
    }
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }

  Future<void> list() async {
    final calls = await database.calls();
    emit(state.copyWith(calls: calls));
  }

  Future<void> clearCalls() async {
    await database.clearCalls();
    list();
  }
}
