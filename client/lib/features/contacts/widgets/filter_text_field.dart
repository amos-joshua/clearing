import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cubit.dart';
import '../bloc/state.dart';


class ContactsFilterTextField extends StatelessWidget {
  final filterController = TextEditingController();

  ContactsFilterTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactsCubit, ContactsState>(
      builder: (context, state) {
        if (state.filter.isEmpty && (state.contacts.length < 5)) {
          return const SizedBox();
        }
        filterController.text = state.filter;

        return TextField(
          controller: filterController,
          onChanged: (filter) => context.read<ContactsCubit>().list(filter.toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Filter...',
            hintStyle: const TextStyle(color: Colors.black38),
            suffix: state.filter.isEmpty ? null : IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                filterController.text = '';
                context.read<ContactsCubit>().list('');
              },
            ),
            border: InputBorder.none
          ),
        );
      }
    );
  }
}
