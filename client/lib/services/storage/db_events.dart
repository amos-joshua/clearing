import '../../features/contacts/model/group.dart';

sealed class DBEvent {}

class DBEventScheduleModified extends DBEvent {}

class DBEventGroupRemoved extends DBEvent {
  final ContactGroup group;
  DBEventGroupRemoved(this.group);
}

class DBEventGroupAdded extends DBEvent {
  final ContactGroup group;
  DBEventGroupAdded(this.group);
}

class DBEventGroupModified extends DBEvent {
  final ContactGroup group;
  DBEventGroupModified(this.group);
}

class DBEventPresetModified extends DBEvent {}

class DBEventCallModified extends DBEvent {}
