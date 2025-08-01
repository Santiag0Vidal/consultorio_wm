// lib/screens/user_list_screen.dart

import 'package:flutter/material.dart';
import 'package:consultorio_wm/database/db_helper.dart'; 
import 'package:consultorio_wm/models/user.dart';
import 'package:consultorio_wm/screens/user_form_screen.dart';
import 'package:consultorio_wm/screens/fms_test_history_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsers() async {
    _users = await _dbHelper.getUsers();
    _filterUsers();
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        return user.name.toLowerCase().contains(query) ||
               user.dni.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _navigateAndRefreshUserForm({User? user}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserFormScreen(user: user),
      ),
    );
    _loadUsers();
  }

  Future<void> _confirmDeleteUser(User user) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que quieres eliminar a ${user.name}? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (shouldDelete == true) {
      await _dbHelper.deleteUser(user.id!);
      _loadUsers();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pacientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateAndRefreshUserForm(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar paciente por nombre o DNI',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: _filteredUsers.isEmpty && _searchController.text.isEmpty
                ? const Center(child: Text('No hay pacientes aún. ¡Añade uno!'))
                : _filteredUsers.isEmpty
                    ? const Center(child: Text('No se encontraron pacientes.'))
                    : ListView.builder(
                        itemCount: _filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredUsers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text(user.name.isNotEmpty ? user.name[0] : ''),
                              ),
                              title: Text(user.name),
                              subtitle: Text('DNI: ${user.dni}'),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _navigateAndRefreshUserForm(user: user);
                                  } else if (value == 'delete') {
                                    _confirmDeleteUser(user);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Editar'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Eliminar'),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FmsTestHistoryScreen(user: user),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
