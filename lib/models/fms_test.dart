// lib/models/fms_test.dart
import 'dart:convert'; // Para codificar y decodificar JSON

// Modelo de datos para un Test FMS
class FmsTest {
  int? id; // ID único del test (opcional para cuando aún no está en la DB)
  int userId; // ID del usuario al que pertenece este test
  DateTime date; // Fecha del test
  int rawScore; // Puntaje bruto
  int totalScore; // Puntaje total
  String comments; // Comentarios generales del test
  Map<String, FmsExerciseResult> exercisesResults; // Resultados de ejercicios individuales

  // Constructor de la clase FmsTest
  FmsTest({
    this.id,
    required this.userId,
    required this.date,
    required this.rawScore,
    required this.totalScore,
    required this.comments,
    required this.exercisesResults,
  });

  // Convierte un objeto FmsTest a un Map para insertarlo en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(), // Convierte DateTime a String ISO 8601
      'rawScore': rawScore,
      'totalScore': totalScore,
      'comments': comments,
      // Convierte el mapa de resultados de ejercicios a una cadena JSON
      'exercisesResults': jsonEncode(
        exercisesResults.map((key, value) => MapEntry(key, value.toMap())),
      ),
    };
  }

  // Crea un objeto FmsTest desde un Map (obtenido de la base de datos)
  factory FmsTest.fromMap(Map<String, dynamic> map) {
    // Decodifica la cadena JSON de resultados de ejercicios a un Map
    final Map<String, dynamic> exercisesJson = jsonDecode(map['exercisesResults']);
    final Map<String, FmsExerciseResult> exercises = exercisesJson.map(
      (key, value) => MapEntry(key, FmsExerciseResult.fromMap(value)),
    );

    return FmsTest(
      id: map['id'],
      userId: map['userId'],
      date: DateTime.parse(map['date']), // Convierte String ISO 8601 a DateTime
      rawScore: map['rawScore'],
      totalScore: map['totalScore'],
      comments: map['comments'],
      exercisesResults: exercises,
    );
  }
}

// Modelo de datos para el resultado de un ejercicio individual del FMS
class FmsExerciseResult {
  int score; // Puntaje del ejercicio
  String comment; // Comentarios específicos del ejercicio
  String? photoPath; // Ruta de la foto del ejercicio (opcional)

  // Constructor
  FmsExerciseResult({
    required this.score,
    this.comment = '',
    this.photoPath,
  });

  // Convierte a Map
  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'comment': comment,
      'photoPath': photoPath,
    };
  }

  // Crea desde Map
  factory FmsExerciseResult.fromMap(Map<String, dynamic> map) {
    return FmsExerciseResult(
      score: map['score'] ?? 0,
      comment: map['comment'] ?? '',
      photoPath: map['photoPath'],
    );
  }
}