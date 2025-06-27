import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/contacts/bloc/cubit.dart';
import '../features/contacts/model/group.dart';
import '../features/groups/bloc/cubit.dart';
import '../features/groups/widgets/widgets.dart';
import '../repositories/contacts/all.dart';
import '../utils/dialogs.dart';

class GroupDetailPage extends StatelessWidget {
  const GroupDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final groupCubit = context.read<GroupCubit>();
    final group = groupCubit.state.group;
    final allContacts = context.read<AllContactsRepository>();
    final groupContacts = allContacts.groupContactsRepository(group);

    return BlocProvider<ContactsCubit>(
      create: (context) => ContactsCubit(contactsRepository: groupContacts),
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Edit group'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: group.catchAll ? 'Cannot delete the ${ContactGroup.catchAllGroupName} group' : 'delete',
                onPressed: group.catchAll ? null : () async {
                  final groups = context.read<GroupsCubit>();
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final confirmed = await ConfirmDialog(context).show(title: "Delete '${group.name}'?");
                  if (confirmed) {
                    groups.remove(group);
                    navigator.pop();
                    final snackBar = SnackBar(
                      content: ListTile(
                        title: Text("Removed '${group.name}'", style: const TextStyle(color: Colors.white)),
                        trailing: TextButton(
                            onPressed: () {
                              groups.save(group);
                              scaffoldMessenger.hideCurrentSnackBar();
                            },
                            child: const Text('undo')
                        ),
                      ),
                    );
                    scaffoldMessenger.showSnackBar(snackBar);
                  }
                },
              )
            ],
          ),
          body: const GroupDetailView()
      ),
    );
  }
}
