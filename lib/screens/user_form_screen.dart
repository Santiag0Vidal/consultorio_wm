// lib/screens/user_form_screen.dart
import 'package:flutter/material.dart';
import 'package:consultorio_wm/database/db_helper.dart';
import 'package:consultorio_wm/models/user.dart';

// Pantalla para añadir o editar un usuario
class UserFormScreen extends StatefulWidget {
  final User? user; // El usuario a editar (null si es nuevo)

  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>(); // Clave global para el formulario
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Instancia del ayudante de la base de datos

  // Controladores para los campos de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _primarySportController = TextEditingController();
  final TextEditingController _dominantHemisphereController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _primaryOccupationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Si se pasa un usuario (para edición), precarga sus datos en los controladores
    if (widget.user != null) {
      _nameController.text = widget.user!.name;
      _addressController.text = widget.user!.address;
      _dniController.text = widget.user!.dni;
      _genderController.text = widget.user!.gender;
      _ageController.text = widget.user!.age.toString();
      _primarySportController.text = widget.user!.primarySport;
      _dominantHemisphereController.text = widget.user!.dominantHemisphere;
      _phoneController.text = widget.user!.phone;
      _weightController.text = widget.user!.weight.toString();
      _heightController.text = widget.user!.height.toString();
      _primaryOccupationController.text = widget.user!.primaryOccupation;
    }
  }

  @override
  void dispose() {
    // Libera los controladores al destruir el widget
    _nameController.dispose();
    _addressController.dispose();
    _dniController.dispose();
    _genderController.dispose();
    _ageController.dispose();
    _primarySportController.dispose();
    _dominantHemisphereController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _primaryOccupationController.dispose();
    super.dispose();
  }

  // Guarda o actualiza un usuario en la base de datos
  Future<void> _saveUser() async {
    if (_formKey.currentState!.validate()) {
      final newUser = User(
        id: widget.user?.id, // Si es edición, usa el ID existente
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        dni: _dniController.text.trim(),
        gender: _genderController.text.trim(),
        age: int.tryParse(_ageController.text.trim()) ?? 0, // Convierte a int, por defecto 0
        primarySport: _primarySportController.text.trim(),
        dominantHemisphere: _dominantHemisphereController.text.trim(),
        phone: _phoneController.text.trim(),
        weight: double.tryParse(_weightController.text.trim()) ?? 0.0, // Convierte a double
        height: double.tryParse(_heightController.text.trim()) ?? 0.0, // Convierte a double
        primaryOccupation: _primaryOccupationController.text.trim(),
      );

      try {
        if (widget.user == null) {
          // Si es un nuevo usuario, inserta
          await _dbHelper.insertUser(newUser);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paciente añadido exitosamente')),
          );
        } else {
          // Si es un usuario existente, actualiza
          await _dbHelper.updateUser(newUser);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Paciente actualizado exitosamente')),
          );
        }
        Navigator.pop(context); // Regresa a la pantalla anterior
      } catch (e) {
        // Manejo de errores, por ejemplo, DNI duplicado
        String errorMessage = 'Error al guardar el paciente. ';
        if (e.toString().contains('UNIQUE constraint failed')) {
          errorMessage += 'El DNI ya existe.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Añadir Paciente' : 'Editar Paciente'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, 'Nombre Completo', validator: _requiredValidator),
              _buildTextField(_addressController, 'Dirección', validator: _requiredValidator),
              _buildTextField(_dniController, 'DNI', keyboardType: TextInputType.number, validator: _requiredValidator),
              _buildTextField(_genderController, 'Género'),
              _buildTextField(_ageController, 'Edad', keyboardType: TextInputType.number),
              _buildTextField(_primarySportController, 'Deporte Primario'),
              _buildTextField(_dominantHemisphereController, 'Hemisferio Dominante'),
              _buildTextField(_phoneController, 'Teléfono', keyboardType: TextInputType.phone),
              _buildTextField(_weightController, 'Peso (kg)', keyboardType: TextInputType.number),
              _buildTextField(_heightController, 'Altura (cm)', keyboardType: TextInputType.number),
              _buildTextField(_primaryOccupationController, 'Ocupación Primaria'),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveUser,
                  icon: const Icon(Icons.save),
                  label: Text(widget.user == null ? 'Guardar Paciente' : 'Actualizar Paciente'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper para construir campos de texto con validación
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Ingresa $label',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  // Validador de campo requerido
  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo es requerido';
    }
    return null;
  }
}
