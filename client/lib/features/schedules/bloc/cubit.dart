import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/storage/database.dart';
import '../../presets/model/schedule.dart';
import 'state.dart';

class ScheduleCubit extends Cubit<ScheduleState> {
  final Database database;
  ScheduleCubit(Schedule schedule, {required this.database})
    : super(ScheduleState(schedule: schedule));

  void toggleDay(int day) {
    if (state.schedule.days.contains(day)) {
      state.schedule.days.remove(day);
    } else {
      state.schedule.days.add(day);
    }
    database.saveSchedule(state.schedule);
    emit(state.copyWith(daysNonce: state.daysNonce + 1));
  }

  void updateDays(List<int> newDays) {
    state.schedule.days = newDays;
    database.saveSchedule(state.schedule);
    emit(state.copyWith(daysNonce: state.daysNonce + 1));
  }

  void updateStartTime(TimeOfDay newTime) {
    state.schedule.startTime = newTime;
    database.saveSchedule(state.schedule);
    emit(state.copyWith(timeRangeNonce: state.timeRangeNonce + 1));
  }

  void updateEndTime(TimeOfDay newTime) {
    state.schedule.endTime = newTime;
    database.saveSchedule(state.schedule);
    emit(state.copyWith(timeRangeNonce: state.timeRangeNonce + 1));
  }

  static Widget provider(Schedule schedule, {required Widget child}) {
    return BlocProvider(
      create: (context) =>
          ScheduleCubit(schedule, database: context.read<Database>()),
      child: child,
    );
  }

  static BlocBuilder<ScheduleCubit, ScheduleState> builder(
    Widget Function(BuildContext, ScheduleState) builder,
  ) => BlocBuilder(builder: builder);
}
