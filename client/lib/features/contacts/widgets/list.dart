import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cubit.dart';
import '../model/contact.dart';
import 'tile.dart';

class ContactsList extends StatelessWidget {
  final bool allowSelection;
  final bool allowDelete;
  final void Function(Contact)? onSelect;

  const ContactsList({required this.allowSelection, this.allowDelete = false, this.onSelect, super.key});

  Widget loadingSpinner() => const Center(
      child: CircularProgressIndicator()
  );

  Widget emptyList() => const Center(
    child: Text('(none)', style: TextStyle(color: Colors.black45))
  );

  Widget listView(List<Contact> contacts, List<Contact> selected) => ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        final onSelect = this.onSelect;
        return ContactTile(
          key: ValueKey(contact.id),
          contact,
          isSelected: selected.any((selected) => selected.id == contact.id),
          onTap: allowSelection ? () {
            if (onSelect != null) {
              onSelect(contact);
            }
            context.read<ContactsCubit>().toggleSelection(contact);
          } : null,
          trailingIcon: allowDelete ? const Icon(Icons.delete) : null,
          onTrailing: allowDelete ? () {
            context.read<ContactsCubit>().remove(contact);
            final snackBar = SnackBar(
              content: ListTile(
                title: Text("Removed '${contact.displayName}'", style: const TextStyle(color: Colors.white),),
                trailing: TextButton(
                  child: const Text('undo'),
                  onPressed: () {
                    context.read<ContactsCubit>().add(contact);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                )
              )
            );
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          } : null
        );
      },
    );

  @override
  Widget build(BuildContext context) {
    final contacts = context.watch<ContactsCubit>();
    return contacts.state.loading ? loadingSpinner() : contacts.state.contacts.isEmpty ? emptyList() : listView(contacts.state.contacts, contacts.state.selected);
  }
      
}