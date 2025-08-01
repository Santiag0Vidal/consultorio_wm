// lib/utils/csv_exporter.dart
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:consultorio_wm/models/fms_test.dart';
import 'package:permission_handler/permission_handler.dart'; // Importa para manejar permisos

// Clase para exportar datos a formato CSV
class CsvExporter {
  // Encabezados para el archivo CSV de tests FMS
  static const List<String> _fmsHeaders = [
    'Fecha Test',
    'Puntaje Bruto',
    'Puntaje Total',
    'Comentarios Generales',
    'SENTADILLA PROFUNDA_Puntaje',
    'SENTADILLA PROFUNDA_Comentarios',
    'SENTADILLA PROFUNDA_Foto',
    'PASO CON OBSTÁCULO_I_Puntaje',
    'PASO CON OBSTÁCULO_I_Comentarios',
    'PASO CON OBSTÁCULO_I_Foto',
    'PASO CON OBSTÁCULO_D_Puntaje',
    'PASO CON OBSTÁCULO_D_Comentarios',
    'PASO CON OBSTÁCULO_D_Foto',
    'ESTOCADA EN LÍNEA_I_Puntaje',
    'ESTOCADA EN LÍNEA_I_Comentarios',
    'ESTOCADA EN LÍNEA_I_Foto',
    'ESTOCADA EN LÍNEA_D_Puntaje',
    'ESTOCADA EN LÍNEA_D_Comentarios',
    'ESTOCADA EN LÍNEA_D_Foto',
    'MOVILIDAD DE HOMBRO_I_Puntaje',
    'MOVILIDAD DE HOMBRO_I_Comentarios',  
    'MOVILIDAD DE HOMBRO_I_Foto',
    'MOVILIDAD DE HOMBRO_D_Puntaje',
    'MOVILIDAD DE HOMBRO_D_Comentarios',
    'MOVILIDAD DE HOMBRO_D_Foto',
    'TEST DE PINZAMIENTO_I_Puntaje',
    'TEST DE PINZAMIENTO_I_Comentarios',
    'TEST DE PINZAMIENTO_I_Foto',
    'TEST DE PINZAMIENTO_D_Puntaje',
    'TEST DE PINZAMIENTO_D_Comentarios',
    'TEST DE PINZAMIENTO_D_Foto',
    'ESTABILIDAD ROTATORIA_I_Puntaje',
    'ESTABILIDAD ROTATORIA_I_Comentarios',
    'ESTABILIDAD ROTATORIA_I_Foto',
    'ESTABILIDAD ROTATORIA_D_Puntaje',
    'ESTABILIDAD ROTATORIA_D_Comentarios',
    'ESTABILIDAD ROTATORIA_D_Foto',
    'ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_I_Puntaje',
    'ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_I_Comentarios',
    'ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_I_Foto',
    'ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_D_Puntaje',
    'ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_D_Comentarios',
    'ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_D_Foto',
    'FLEXIONES CON ESTABILIDAD DEL TRONCO_Puntaje',
    'FLEXIONES CON ESTABILIDAD DEL TRONCO_Comentarios',
    'FLEXIONES CON ESTABILIDAD DEL TRONCO_Foto',
    'TEST DE BALANCEO POSTERIOR (ALABANZA)_Puntaje',
    'TEST DE BALANCEO POSTERIOR (ALABANZA)_Comentarios',
    'TEST DE BALANCEO POSTERIOR (ALABANZA)_Foto',
  ];

  // Exporta una lista de tests FMS a un archivo CSV
  static Future<void> exportFmsTestsToCsv(
    String userName,
    List<FmsTest> tests,
    ScaffoldMessengerState messenger,
  ) async {
    // Solicitar permiso de almacenamiento
    var status = await Permission.storage.request();
    if (status.isDenied) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Permiso de almacenamiento denegado. No se puede exportar el archivo.')),
      );
      return;
    }
     if (status.isPermanentlyDenied) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Permiso de almacenamiento denegado permanentemente. Por favor, habilítalo en la configuración.')),
      );
      openAppSettings();
      return;
    }

    List<List<dynamic>> rows = [];
    rows.add(_fmsHeaders); // Añade los encabezados

    // Itera sobre cada test y construye la fila de datos
    for (var test in tests) {
      List<dynamic> row = [
        DateFormat('yyyy-MM-dd HH:mm').format(test.date),
        test.rawScore,
        test.totalScore,
        test.comments,
      ];

      // Añade los datos de cada ejercicio en el orden de los encabezados
      // Asegúrate de que las claves aquí coincidan con las claves en _fmsHeaders
      // y en FmsTestFormScreen
      final Map<String, dynamic> orderedExerciseData = {};

      // Función helper para obtener datos de un ejercicio con seguridad
      dynamic getExerciseValue(String key, String field) {
        final result = test.exercisesResults[key];
        if (result != null) {
          if (field == 'score') return result.score;
          if (field == 'comment') return result.comment;
          if (field == 'photoPath') return result.photoPath ?? '';
        }
        return ''; // Retorna vacío si no se encuentra
      }

      // Populate orderedExerciseData in a fixed order matching headers
      orderedExerciseData['SENTADILLA PROFUNDA_Puntaje'] = getExerciseValue('SENTADILLA PROFUNDA', 'score');
      orderedExerciseData['SENTADILLA PROFUNDA_Comentarios'] = getExerciseValue('SENTADILLA PROFUNDA', 'comment');
      orderedExerciseData['SENTADILLA PROFUNDA_Foto'] = getExerciseValue('SENTADILLA PROFUNDA', 'photoPath');

      orderedExerciseData['PASO CON OBSTÁCULO_I_Puntaje'] = getExerciseValue('PASO CON OBSTÁCULO_I', 'score');
      orderedExerciseData['PASO CON OBSTÁCULO_I_Comentarios'] = getExerciseValue('PASO CON OBSTÁCULO_I', 'comment');
      orderedExerciseData['PASO CON OBSTÁCULO_I_Foto'] = getExerciseValue('PASO CON OBSTÁCULO_I', 'photoPath');

      orderedExerciseData['PASO CON OBSTÁCULO_D_Puntaje'] = getExerciseValue('PASO CON OBSTÁCULO_D', 'score');
      orderedExerciseData['PASO CON OBSTÁCULO_D_Comentarios'] = getExerciseValue('PASO CON OBSTÁCULO_D', 'comment');
      orderedExerciseData['PASO CON OBSTÁCULO_D_Foto'] = getExerciseValue('PASO CON OBSTÁCULO_D', 'photoPath');

      orderedExerciseData['ESTOCADA EN LÍNEA_I_Puntaje'] = getExerciseValue('ESTOCADA EN LÍNEA_I', 'score');
      orderedExerciseData['ESTOCADA EN LÍNEA_I_Comentarios'] = getExerciseValue('ESTOCADA EN LÍNEA_I', 'comment');
      orderedExerciseData['ESTOCADA EN LÍNEA_I_Foto'] = getExerciseValue('ESTOCADA EN LÍNEA_I', 'photoPath');

      orderedExerciseData['ESTOCADA EN LÍNEA_D_Puntaje'] = getExerciseValue('ESTOCADA EN LÍNEA_D', 'score');
      orderedExerciseData['ESTOCADA EN LÍNEA_D_Comentarios'] = getExerciseValue('ESTOCADA EN LÍNEA_D', 'comment');
      orderedExerciseData['ESTOCADA EN LÍNEA_D_Foto'] = getExerciseValue('ESTOCADA EN LÍNEA_D', 'photoPath');

      orderedExerciseData['MOVILIDAD DE HOMBRO_I_Puntaje'] = getExerciseValue('MOVILIDAD DE HOMBRO_I', 'score');
      orderedExerciseData['MOVILIDAD DE HOMBRO_I_Comentarios'] = getExerciseValue('MOVILIDAD DE HOMBRO_I', 'comment');
      orderedExerciseData['MOVILIDAD DE HOMBRO_I_Foto'] = getExerciseValue('MOVILIDAD DE HOMBRO_I', 'photoPath');

      orderedExerciseData['MOVILIDAD DE HOMBRO_D_Puntaje'] = getExerciseValue('MOVILIDAD DE HOMBRO_D', 'score');
      orderedExerciseData['MOVILIDAD DE HOMBRO_D_Comentarios'] = getExerciseValue('MOVILIDAD DE HOMBRO_D', 'comment');
      orderedExerciseData['MOVILIDAD DE HOMBRO_D_Foto'] = getExerciseValue('MOVILIDAD DE HOMBRO_D', 'photoPath');

      orderedExerciseData['TEST DE PINZAMIENTO_I_Puntaje'] = getExerciseValue('TEST DE PINZAMIENTO_I', 'score');
      orderedExerciseData['TEST DE PINZAMIENTO_I_Comentarios'] = getExerciseValue('TEST DE PINZAMIENTO_I', 'comment');
      orderedExerciseData['TEST DE PINZAMIENTO_I_Foto'] = getExerciseValue('TEST DE PINZAMIENTO_I', 'photoPath');

      orderedExerciseData['TEST DE PINZAMIENTO_D_Puntaje'] = getExerciseValue('TEST DE PINZAMIENTO_D', 'score');
      orderedExerciseData['TEST DE PINZAMIENTO_D_Comentarios'] = getExerciseValue('TEST DE PINZAMIENTO_D', 'comment');
      orderedExerciseData['TEST DE PINZAMIENTO_D_Foto'] = getExerciseValue('TEST DE PINZAMIENTO_D', 'photoPath');

      orderedExerciseData['ESTABILIDAD ROTATORIA_I_Puntaje'] = getExerciseValue('ESTABILIDAD ROTATORIA_I', 'score');
      orderedExerciseData['ESTABILIDAD ROTATORIA_I_Comentarios'] = getExerciseValue('ESTABILIDAD ROTATORIA_I', 'comment');
      orderedExerciseData['ESTABILIDAD ROTATORIA_I_Foto'] = getExerciseValue('ESTABILIDAD ROTATORIA_I', 'photoPath');

      orderedExerciseData['ESTABILIDAD ROTATORIA_D_Puntaje'] = getExerciseValue('ESTABILIDAD ROTATORIA_D', 'score');
      orderedExerciseData['ESTABILIDAD ROTATORIA_D_Comentarios'] = getExerciseValue('ESTABILIDAD ROTATORIA_D', 'comment');
      orderedExerciseData['ESTABILIDAD ROTATORIA_D_Foto'] = getExerciseValue('ESTABILIDAD ROTATORIA_D', 'photoPath');

      orderedExerciseData['ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_I_Puntaje'] = getExerciseValue('ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_I', 'score');
      orderedExerciseData['ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_I_Comentarios'] = getExerciseValue('ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_I', 'comment');
      orderedExerciseData['ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_I_Foto'] = getExerciseValue('ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_I', 'photoPath');

      orderedExerciseData['ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_D_Puntaje'] = getExerciseValue('ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_D', 'score');
      orderedExerciseData['ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_D_Comentarios'] = getExerciseValue('ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_D', 'comment');
      orderedExerciseData['ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_D_Foto'] = getExerciseValue('ELEVACIÓN ACTIVA CON PIERNA EXTENDIDA_D', 'photoPath');

      orderedExerciseData['FLEXIONES CON ESTABILIDAD DEL TRONCO_Puntaje'] = getExerciseValue('FLEXIONES CON ESTABILIDAD DEL TRONCO', 'score');
      orderedExerciseData['FLEXIONES CON ESTABILIDAD DEL TRONCO_Comentarios'] = getExerciseValue('FLEXIONES CON ESTABILIDAD DEL TRONCO', 'comment');
      orderedExerciseData['FLEXIONES CON ESTABILIDAD DEL TRONCO_Foto'] = getExerciseValue('FLEXIONES CON ESTABILIDAD DEL TRONCO', 'photoPath');

      orderedExerciseData['TEST DE BALANCEO POSTERIOR (ALABANZA)_Puntaje'] = getExerciseValue('TEST DE BALANCEO POSTERIOR (ALABANZA)', 'score');
      orderedExerciseData['TEST DE BALANCEO POSTERIOR (ALABANZA)_Comentarios'] = getExerciseValue('TEST DE BALANCEO POSTERIOR (ALABANZA)', 'comment');
      orderedExerciseData['TEST DE BALANCEO POSTERIOR (ALABANZA)_Foto'] = getExerciseValue('TEST DE BALANCEO POSTERIOR (ALABANZA)', 'photoPath');

      // Add values to the row in the exact order of _fmsHeaders
      for (var header in _fmsHeaders.sublist(4)) { // Start from the first exercise header
        row.add(orderedExerciseData[header]);
      }

      rows.add(row);
    }

    // Convierte la lista de listas en una cadena CSV
    String csv = const ListToCsvConverter().convert(rows);

    try {
      // Obtiene el directorio de documentos de la aplicación
      final directory = await getApplicationDocumentsDirectory();
      // Crea un nombre de archivo único
      final filePath = '${directory.path}/${userName.replaceAll(' ', '_')}_FMS_Tests_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv';
      final file = File(filePath);
      await file.writeAsString(csv); // Escribe la cadena CSV en el archivo

      messenger.showSnackBar(
        SnackBar(content: Text('Tests exportados a: $filePath')),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error al exportar tests: $e')),
      );
    }
  }
}