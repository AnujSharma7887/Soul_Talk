import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soul_talk/services/database/database_provider.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  late final listeningProvider = Provider.of<DatabaseProvider>(context);
  late final databaseProvider =
      Provider.of<DatabaseProvider>(context, listen: false);

  @override
  void initState() {
    super.initState();
    loadBlockedUsers();
  }

  Future<void> loadBlockedUsers() async {
    await databaseProvider.loadBlockedUsers();
  }

  void _showUnblockConfirmationBox(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Unblock User"),
        content: Text("Are you sure you want to unblock this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await databaseProvider.unblockUser(userId);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("User Unblocked"),
                ),
              );
            },
            child: const Text("Unblock"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final blockedUsers = listeningProvider.blockedUsers;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text("B L O C K E D . U S E R S"),
        centerTitle: true,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: blockedUsers.isEmpty
            ? Center(
                child: Text("No Blocked Users"),
              )
            : ListView.builder(
                itemCount: blockedUsers.length,
                itemBuilder: (context, index) {
                  final user = blockedUsers[index];
                  return Container(
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.symmetric(horizontal: 17, vertical: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.secondary),
                    child: ListTile(
                        title: Text(
                          user.name,
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.inversePrimary),
                        ),
                        subtitle: Text(
                          '@' + user.username,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.block,
                              color: Theme.of(context).colorScheme.primary),
                          onPressed: () =>
                              _showUnblockConfirmationBox(user.uid),
                        )),
                  );
                },
              ),
      ),
    );
  }
}
