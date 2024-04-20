import 'package:flutter/material.dart';
import 'package:social_media_app/services/firestore_service.dart';
import 'package:social_media_app/widgets/user_box.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> _userList = [];
  List<Map<String, dynamic>> _filteredUserList = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    List<Map<String, dynamic>> users = await _firestoreService.getAllUsers();
    setState(() {
      _userList = users;
      _filteredUserList =
          users; // Initially, filtered list is the same as the full list
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filteredUserList = _userList.where((user) {
        bool contains = user['firstName'].toLowerCase().contains(_searchQuery);
        return contains;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Users'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _updateSearchQuery,
              decoration: InputDecoration(
                labelText: 'Search by username',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredUserList.length,
              itemBuilder: (context, index) {
                return buildUserTile(_filteredUserList[index], context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
