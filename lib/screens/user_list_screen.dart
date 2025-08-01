// lib/screens/user_list_screen.dart
import 'package:flutter/material.dart';
import 'package:kinesiology_app/database/db_helper.dart';
import 'package:kinesiology_app/models/user.dart';
import 'package:kinesiology_app/screens/user_form_screen.dart';
import 'package:kinesiology_app/screens/fms_test_history_screen.dart';

// Pantalla para mostrar la lista de usuarios y permitir búsqueda
class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Instancia del ayudante de la base de datos
  List<User> _users = []; // Lista de todos los usuarios
  List<User> _filteredUsers = []; // Lista de usuarios filtrados
  final TextEditingController _searchController = TextEditingController(); // Controlador para el campo de búsqueda

  @override
  void initState() {
    super.initState();
    _loadUsers(); // Carga los usuarios al iniciar la pantalla
    _searchController.addListener(_filterUsers); // Escucha cambios en el campo de búsqueda
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers); // Elimina el listener al destruir el widget
    _searchController.dispose(); // Libera el controlador
    super.dispose();
  }

  // Carga todos los usuarios desde la base de datos
  Future<void> _loadUsers() async {
    final users = await _dbHelper.getUsers();
    setState(() {
      _users = users;
      _filterUsers(); // Aplica el filtro inicial (muestra todos si la búsqueda está vacía)
    });
  }

  // Filtra los usuarios según el texto de búsqueda (nombre o DNI)
  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        return user.name.toLowerCase().contains(query) ||
            user.dni.toLowerCase().contains(query);
      }).toList();
    });
  }

  // Navega a la pantalla del formulario de usuario para añadir o editar
  void _navigateAndRefreshUserForm({User? user}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserFormScreen(user: user)),
    );
    _loadUsers(); // Recarga los usuarios después de añadir/editar
  }

  // Muestra un diálogo de confirmación antes de eliminar un usuario
  Future<void> _confirmDeleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Estás seguro de que quieres eliminar a ${user.name}? Todos los tests FMS asociados también serán eliminados.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _dbHelper.deleteUser(user.id!);
      _loadUsers(); // Recarga la lista después de eliminar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Usuario ${user.name} eliminado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Pacientes'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por Nombre o DNI',
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (text) => _filterUsers(),
            ),
          ),
        ),
      ),
      body: _filteredUsers.isEmpty && _searchController.text.isNotEmpty
          ? const Center(child: Text('No se encontraron usuarios.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    title: Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.blueGrey,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4.0),
                        Text('DNI: ${user.dni}'),
                        Text('Edad: ${user.age}'),
                        Text('Teléfono: ${user.phone}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _navigateAndRefreshUserForm(user: user),
                          tooltip: 'Editar Usuario',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteUser(user),
                          tooltip: 'Eliminar Usuario',
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navega a la pantalla del historial de tests FMS para este usuario
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FmsTestHistoryScreen(user: user),
                        ),
                      ).then((_) => _loadUsers()); // Recarga por si se eliminaron tests
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndRefreshUserForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('Nuevo Paciente'),
      ),
    );
  }
}
