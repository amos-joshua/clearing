import 'package:flutter/material.dart';

import '../model/contact.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final bool isSelected;
  final  Icon? trailingIcon;
  final void Function()? onTap;
  final void Function()? onTrailing;
  const ContactTile(this.contact, {this.isSelected = false, this.onTap, this.trailingIcon, this.onTrailing, super.key});

  @override
  Widget build(BuildContext context) {
    final trailingIcon = this.trailingIcon;
    return ListTile(
      leading: const Icon(Icons.account_circle),
      title: Text(contact.displayName),
      subtitle: Text(contact.emails.isEmpty ? '(no email)' : contact.emails.join(', ')),
      selected: isSelected,
      trailing: trailingIcon == null ? null : IconButton(
        icon: trailingIcon,
        onPressed: onTrailing,
      ),
      onTap: onTap,
    );
  }
}