import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';

class Usuarios extends StatefulWidget {
  final String userType;

  const Usuarios({Key? key, required this.userType}) : super(key: key);

  @override
  _UsuariosState createState() => _UsuariosState();
}

class _UsuariosState extends State<Usuarios> {
  late Future<Box<User>> _userBoxFuture;
  Box<User>? _userBox;
  int? _selectedUserIndex;

  @override
  void initState() {
    super.initState();
    _userBoxFuture = _initializeHive();
  }

  Future<Box<User>> _initializeHive() async {
    final box = await Hive.openBox<User>('users');
    setState(() {
      _userBox = box;
    });
    return box;
  }

  void _addUser(String name, String role) {
    final newUser = User(
        id: DateTime.now().toString(),
        name: name,
        role: role,
        password: 'root');
    _userBox?.add(newUser);
    setState(() {});
  }

  void _editUser(int index, String name, String role) {
    final user = _userBox?.getAt(index);
    if (user != null) {
      final updatedUser = User(
          id: user.id, name: name, role: role, password: 'root');
      _userBox?.putAt(index, updatedUser);
      setState(() {});
    }
  }

  void _deleteUser(int index) {
    _userBox?.deleteAt(index);
    setState(() {});
  }

  void _showUserForm({int? index}) {
    final isEditing = index != null;
    final nameController = TextEditingController(
      text: isEditing ? _userBox?.getAt(index!)?.name : '',
    );

    String? selectedRole = isEditing ? _userBox?.getAt(index!)?.role.toLowerCase() : 'empleado';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Usuario' : 'Agregar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              DropdownButtonFormField<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'administrador', child: Text('Administrador')),
                  DropdownMenuItem(value: 'empleado', child: Text('Empleado')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedRole = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Tipo de Usuario'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text;
                final role = selectedRole;
                if (name.isNotEmpty && role != null) {
                  if (isEditing) {
                    _editUser(index!, name, role);
                  } else {
                    _addUser(name, role);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box<User>>(
      future: _userBoxFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Usuarios'),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Usuarios'),
            ),
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        _userBox = snapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Usuarios'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showUserForm(), // Llamar a la función para agregar usuarios
              ),
            ],
          ),
          body: _userBox!.isEmpty
              ? const Center(child: Text('No hay usuarios'))
              : ListView.builder(
            itemCount: _userBox!.length,
            itemBuilder: (context, index) {
              final user = _userBox!.getAt(index);
              return Card(
                margin: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text(user!.name),
                  subtitle: Text('Tipo: ${user.role}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showUserForm(index: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteUser(index),
                      ),
                    ],
                  ),
                  selected: _selectedUserIndex == index,
                  onTap: () {
                    setState(() {
                      _selectedUserIndex = index;
                    });
                  },
                ),
              );
            },
          ),
          bottomNavigationBar: widget.userType == 'administrador'
              ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showUserForm(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'Agregar',
                    style: GoogleFonts.josefinSans(
                        fontSize: 18, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectedUserIndex != null
                      ? () => _showUserForm(index: _selectedUserIndex!)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'Modificar',
                    style: GoogleFonts.josefinSans(
                        fontSize: 18, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: _selectedUserIndex != null
                      ? () => _deleteUser(_selectedUserIndex!)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'Eliminar',
                    style: GoogleFonts.josefinSans(
                        fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          )
              : null,
        );
      },
    );
  }
}