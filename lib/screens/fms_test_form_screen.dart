// lib/screens/fms_test_form_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kinesiology_app/database/db_helper.dart';
import 'package:kinesiology_app/models/fms_test.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart'; // Importa para manejar permisos

// Pantalla para añadir o editar un test FMS
class FmsTestFormScreen extends StatefulWidget {
  final int userId; // ID del usuario al que pertenece este test
  final FmsTest? test; // El test a editar (null si es nuevo)

  const FmsTestFormScreen({super.key, required this.userId, this.test});

  @override
  State<FmsTestFormScreen> createState() => _FmsTestFormScreenState();
}

class _FmsTestFormScreenState extends State<FmsTestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ImagePicker _picker = ImagePicker(); // Instancia para seleccionar imágenes

  DateTime _selectedDate = DateTime.now(); // Fecha del test
  final TextEditingController _rawScoreController = TextEditingController();
  final TextEditingController _totalScoreController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  // Mapa para almacenar los resultados de cada ejercicio
  Map<String, FmsExerciseResult> _exerciseResults = {};

  // Lista de ejercicios FMS, con indicación si tienen lados I/D
  final List<Map<String, dynamic>> _fmsExercises = const [
    {'name': 'SENTADILLA PROFUNDA', 'hasSides': false},
    {'name': 'PASO CON OBSTÁCULO', 'hasSides': true},
    {'name': 'ESTOCADA EN LÍNEA', 'hasSides': true},
    {'name': 'MOVILIDAD DE HOMBRO', 'hasSides': true},
    {'name': 'TEST DE PINZAMIENTO', 'hasSides': true},
    {'name': 'ESTABILIDAD ROTATORIA', 'hasSides': true},
    {'name': 'ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA', 'hasSides': true},
    {'name': 'FLEXIONES CON ESTABILIDAD DEL TRONCO', 'hasSides': false},
    {'name': 'TEST DE BALANCEO POSTERIOR (ALABANZA)', 'hasSides': false},
  ];

  @override
  void initState() {
    super.initState();
    // Si se pasa un test (para edición), precarga sus datos
    if (widget.test != null) {
      _selectedDate = widget.test!.date;
      _rawScoreController.text = widget.test!.rawScore.toString();
      _totalScoreController.text = widget.test!.totalScore.toString();
      _commentsController.text = widget.test!.comments;
      _exerciseResults = Map.from(widget.test!.exercisesResults); // Copia el mapa existente
    } else {
      // Inicializa los resultados de ejercicios para un nuevo test
      _fmsExercises.forEach((exercise) {
        if (exercise['hasSides']) {
          _exerciseResults['${exercise['name']}_I'] = FmsExerciseResult(score: 0);
          _exerciseResults['${exercise['name']}_D'] = FmsExerciseResult(score: 0);
        } else {
          _exerciseResults[exercise['name']] = FmsExerciseResult(score: 0);
        }
      });
    }
  }

  @override
  void dispose() {
    _rawScoreController.dispose();
    _totalScoreController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  // Muestra un selector de fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Toma una foto y actualiza el resultado del ejercicio
  Future<void> _takePhoto(String exerciseKey) async {
    // Solicitar permiso de cámara
    var status = await Permission.camera.request();
    if (status.isGranted) {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() {
          // Obtener el resultado del ejercicio existente o crear uno nuevo
          final result = _exerciseResults[exerciseKey] ?? FmsExerciseResult(score: 0);
          result.photoPath = image.path; // Almacena la ruta de la imagen
          _exerciseResults[exerciseKey] = result;
        });
      }
    } else if (status.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de cámara denegado. Por favor, habilítalo en la configuración.')),
      );
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de cámara denegado permanentemente. Por favor, habilítalo en la configuración.')),
      );
      openAppSettings(); // Abre la configuración de la aplicación
    }
  }

  // Guarda o actualiza un test FMS en la base de datos
  Future<void> _saveFmsTest() async {
    if (_formKey.currentState!.validate()) {
      final newTest = FmsTest(
        id: widget.test?.id,
        userId: widget.userId,
        date: _selectedDate,
        rawScore: int.tryParse(_rawScoreController.text.trim()) ?? 0,
        totalScore: int.tryParse(_totalScoreController.text.trim()) ?? 0,
        comments: _commentsController.text.trim(),
        exercisesResults: _exerciseResults,
      );

      if (widget.test == null) {
        await _dbHelper.insertFmsTest(newTest);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test FMS añadido exitosamente')),
        );
      } else {
        await _dbHelper.updateFmsTest(newTest);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test FMS actualizado exitosamente')),
        );
      }
      Navigator.pop(context); // Regresa a la pantalla anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.test == null ? 'Añadir Test FMS' : 'Editar Test FMS'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de información general del test
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información General del Test',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.blueAccent),
                      ),
                      const Divider(height: 20, thickness: 1),
                      ListTile(
                        title: Text('Fecha del Test: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                      _buildTextField(_rawScoreController, 'Puntaje Bruto', keyboardType: TextInputType.number),
                      _buildTextField(_totalScoreController, 'Puntaje Total', keyboardType: TextInputType.number),
                      _buildTextField(_commentsController, 'Comentarios Generales', maxLines: 3),
                    ],
                  ),
                ),
              ),

              // Sección de resultados de ejercicios individuales
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resultados de Ejercicios FMS',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.blueAccent),
                      ),
                      const Divider(height: 20, thickness: 1),
                      ..._fmsExercises.map((exercise) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                exercise['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            if (exercise['hasSides']) ...[
                              _buildExerciseInput('${exercise['name']}_I', 'Lado Izquierdo'),
                              _buildExerciseInput('${exercise['name']}_D', 'Lado Derecho'),
                            ] else ...[
                              _buildExerciseInput(exercise['name'], 'Resultado'),
                            ],
                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveFmsTest,
                  icon: const Icon(Icons.save),
                  label: Text(widget.test == null ? 'Guardar Test' : 'Actualizar Test'),
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

  // Helper para construir campos de texto generales
  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  // Widget para un input de ejercicio FMS (puntaje, comentario, foto)
  Widget _buildExerciseInput(String exerciseKey, String labelSuffix) {
    // Asegura que el FmsExerciseResult exista para esta clave, si no, crea uno por defecto.
    final result = _exerciseResults.putIfAbsent(exerciseKey, () => FmsExerciseResult(score: 0));
    final TextEditingController scoreController = TextEditingController(text: result.score.toString());
    final TextEditingController commentController = TextEditingController(text: result.comment);

    // Escuchar cambios en los controladores para actualizar el modelo
    scoreController.addListener(() {
      setState(() {
        result.score = int.tryParse(scoreController.text) ?? 0;
      });
    });
    commentController.addListener(() {
      setState(() {
        result.comment = commentController.text;
      });
    });

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: scoreController,
                decoration: InputDecoration(
                  labelText: 'Puntaje ($labelSuffix)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Puntaje requerido';
                  final score = int.tryParse(value);
                  if (score == null || score < 0 || score > 3) return 'Debe ser 0-3'; // Rango de puntajes FMS
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 30, color: Colors.deepPurple),
                onPressed: () => _takePhoto(exerciseKey),
                tooltip: 'Tomar foto para $exerciseKey',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: commentController,
          decoration: InputDecoration(
            labelText: 'Comentarios ($labelSuffix)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          maxLines: 2,
        ),
        if (result.photoPath != null && result.photoPath!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(result.photoPath!),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 80, color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }
}
