import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cubit.dart';
import '../bloc/state.dart';

class ContactsCountBanner extends StatelessWidget {
  const ContactsCountBanner({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<ContactsCubit, ContactsState>(
    builder: (context, state) {
      final hasSelected = state.selected.isNotEmpty;
      final text = hasSelected ? '${state.selected.length} selected' : '${state.contacts.length} contacts';
      return ListTile(
        dense: true,
        title: hasSelected ? Text(text) : null,
        trailing: hasSelected ? TextButton(
            onPressed: () {
              context.read<ContactsCubit>().clearSelection();
            },
            child: const Text('clear')
        ) : Text(text),
      );
  });

}