// lib/screens/fms_test_history_screen.dart
import 'package:flutter/material.dart';
import 'package:kinesiology_app/database/db_helper.dart';
import 'package:kinesiology_app/models/user.dart';
import 'package:kinesiology_app/models/fms_test.dart';
import 'package:kinesiology_app/screens/fms_test_form_screen.dart';
import 'package:kinesiology_app/utils/csv_exporter.dart';
import 'package:intl/intl.dart'; // Para formatear la fecha

// Pantalla para mostrar el historial de tests FMS de un usuario
class FmsTestHistoryScreen extends StatefulWidget {
  final User user; // El usuario del que se mostrarán los tests

  const FmsTestHistoryScreen({super.key, required this.user});

  @override
  State<FmsTestHistoryScreen> createState() => _FmsTestHistoryScreenState();
}

class _FmsTestHistoryScreenState extends State<FmsTestHistoryScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper(); // Instancia del ayudante de la base de datos
  List<FmsTest> _fmsTests = []; // Lista de tests FMS

  @override
  void initState() {
    super.initState();
    _loadFmsTests(); // Carga los tests al iniciar la pantalla
  }

  // Carga los tests FMS para el usuario actual
  Future<void> _loadFmsTests() async {
    final tests = await _dbHelper.getFmsTestsForUser(widget.user.id!);
    setState(() {
      _fmsTests = tests;
    });
  }

  // Navega a la pantalla del formulario de test FMS para añadir o editar
  void _navigateAndRefreshFmsTestForm({FmsTest? test}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FmsTestFormScreen(
                userId: widget.user.id!,
                test: test,
              )),
    );
    _loadFmsTests(); // Recarga los tests después de añadir/editar
  }

  // Muestra un diálogo de confirmación antes de eliminar un test
  Future<void> _confirmDeleteFmsTest(FmsTest test) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Test FMS'),
        content: Text(
            '¿Estás seguro de que quieres eliminar el test del ${DateFormat('dd/MM/yyyy').format(test.date)}?'),
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
      await _dbHelper.deleteFmsTest(test.id!);
      _loadFmsTests(); // Recarga la lista después de eliminar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Test del ${DateFormat('dd/MM/yyyy').format(test.date)} eliminado')),
      );
    }
  }

  // Exporta los tests FMS a un archivo CSV
  Future<void> _exportTestsToCsv() async {
    await CsvExporter.exportFmsTestsToCsv(
      widget.user.name,
      _fmsTests,
      ScaffoldMessenger.of(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial FMS de ${widget.user.name}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportTestsToCsv,
            tooltip: 'Exportar a CSV',
          ),
        ],
      ),
      body: _fmsTests.isEmpty
          ? const Center(child: Text('No hay tests FMS registrados para este paciente.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _fmsTests.length,
              itemBuilder: (context, index) {
                final test = _fmsTests[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    title: Text(
                      'Test FMS - ${DateFormat('dd/MM/yyyy').format(test.date)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0,
                        color: Colors.blueGrey,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4.0),
                        Text('Puntaje Bruto: ${test.rawScore}'),
                        Text('Puntaje Total: ${test.totalScore}'),
                        Text('Comentarios: ${test.comments.isNotEmpty ? test.comments : 'N/A'}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _navigateAndRefreshFmsTestForm(test: test),
                          tooltip: 'Editar Test',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteFmsTest(test),
                          tooltip: 'Eliminar Test',
                        ),
                      ],
                    ),
                    onTap: () {
                      // Puedes añadir una vista de detalle del test si es necesario
                      // Por ahora, al tocar se podría abrir el formulario en modo edición también
                      _navigateAndRefreshFmsTestForm(test: test);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateAndRefreshFmsTestForm(),
        icon: const Icon(Icons.add_chart),
        label: const Text('Añadir Nuevo Test'),
      ),
    );
  }
}
