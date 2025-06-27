
import '../../features/contacts/model/contact.dart';
import '../../sample_data/contacts.dart';
import '../storage/storage.dart';

abstract class PhoneContactsService {
  bool get hasContactsPermission;
  Future<void> init(Storage storage);
  Future<void> requestContactsPermission();
  Future<List<Contact>> getAllContacts();
  void onContactsChanged(void Function() callback);
}


class PhoneContactsServiceMock implements PhoneContactsService {
  @override
  bool get hasContactsPermission => true;

  @override
  Future<void> init(Storage storage) async {
  }

  @override
  Future<void> requestContactsPermission() async {
  }

  @override
  Future<List<Contact>> getAllContacts() async => sampleContacts;

  @override
  void onContactsChanged(void Function() callback) {
    // no-op for mock repository
  }
}