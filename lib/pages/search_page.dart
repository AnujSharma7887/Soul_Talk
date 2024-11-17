

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soul_talk/components/my_user_tile.dart';
import 'package:soul_talk/services/database/database_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    final listeningProvider = Provider.of<DatabaseProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 90,
        title: Padding(
          padding: const EdgeInsets.only(left: 9, right: 9, top: 15),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search User..",
              hintStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.tertiary),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                databaseProvider.searchUsers(value);
              } else {
                databaseProvider.searchUsers("");
              }
            },
          ),
        ),
      ),
      body: listeningProvider.searchResult.isEmpty
          ? Center(
              child: Text("No Users Found"),
            )
          : ListView.builder(
              itemCount: listeningProvider.searchResult.length,
              itemBuilder: (context, index) {
                final user = listeningProvider.searchResult[index];
                return MyUserTile(user: user);
              },
            ),
    );
  }
}