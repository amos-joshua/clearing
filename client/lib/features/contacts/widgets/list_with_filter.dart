import 'package:flutter/material.dart';
import '../model/contact.dart';
import 'count_banner.dart';
import 'filter_text_field.dart';
import 'list.dart';

class ContactsListWithFilter extends StatelessWidget {
  final bool allowSelection;
  final bool allowDelete;
  final void Function(Contact)? onSelect;
  const ContactsListWithFilter({this.allowSelection = false, this.allowDelete = false, this.onSelect, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: ContactsFilterTextField(),
        ),
        const ContactsCountBanner(),
        Expanded(
            child: ContactsList(
              allowSelection: allowSelection,
              allowDelete: allowDelete,
              onSelect: onSelect,
            )
        )
      ]
    );
  }

}