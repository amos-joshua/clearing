import 'package:flutter_contacts/flutter_contacts.dart' as fc;
import '../../features/contacts/model/contact.dart';
import '../logging/logging_service.dart';
import '../storage/storage.dart';
import 'phone_contacts.dart';

class PhoneContactsServiceNative implements PhoneContactsService {
  final LoggingService logger;
  bool _hasPermission = false;

  PhoneContactsServiceNative({required this.logger});

  @override
  bool get hasContactsPermission => _hasPermission;

  @override
  Future<void> init(Storage storage) async {
    await requestContactsPermission();
    final contacts = await getAllContacts();
    await storage.refreshContacts(contacts);
  }

  @override
  Future<void> requestContactsPermission() async {
    _hasPermission = await fc.FlutterContacts.requestPermission(readonly: true);
    if (!_hasPermission) {
      logger.warning('contacts permission denied!');
    }
  }

  @override
  Future<List<Contact>> getAllContacts() async {
    if (!_hasPermission) {
      logger.warning(
        'tried accessing contacts without permission, returning an empty list',
      );
      return [];
    }

    final contacts = await fc.FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
    );

    return contacts
        .map(
          (contact) => Contact(
            id: 0, // id 0 is used to insert new objects
            uid: contact.id,
            displayName: contact.displayName,
            firstName: contact.name.first,
            lastName: contact.name.last,
            emails: contact.emails
                .map((email) => email.address)
                .toList(growable: false),
            phoneNumbers: contact.phones
                .map((phone) => Contact.sanitizePhoneNumber(phone.number))
                .toList(growable: false),
            lastUpdated: DateTime.now(),
          ),
        )
        .toList(growable: false);
  }

  @override
  void onContactsChanged(void Function() callback) {
    fc.FlutterContacts.addListener(callback);
  }
}
