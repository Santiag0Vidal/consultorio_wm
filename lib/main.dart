// main.dart
import 'package:flutter/material.dart';
import 'package:consultorio_wm/screens/user_list_screen.dart';
import 'package:consultorio_wm/database/db_helper.dart';

// Punto de entrada de la aplicación
void main() async {
  // Asegura que los widgets de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa la base de datos al inicio de la aplicación
  await DatabaseHelper().initDb();
  runApp(const KinesiologyApp());
}

// Clase principal de la aplicación, un StatelessWidget ya que la raíz no cambia
class KinesiologyApp extends StatelessWidget {
  const KinesiologyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kinesiology App',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema principal de la aplicación
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueAccent, // Color de la barra de la aplicación
          foregroundColor: Colors.white, // Color del texto de la barra
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.blueAccent, // Color del botón flotante
          foregroundColor: Colors.white, // Color del icono del botón flotante
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0), // Bordes redondeados para campos de texto
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2.0),
          ),
        ),
        // CORRECCIÓN AQUÍ: Usar CardThemeData en lugar de CardTheme
        cardTheme: CardThemeData( // <--- CAMBIO AQUÍ
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Bordes redondeados para tarjetas
          ),
          elevation: 4.0, // Elevación de las tarjetas
        ),
      ),
      home: const UserListScreen(), // La pantalla inicial es la lista de usuarios
      debugShowCheckedModeBanner: false, // Oculta el banner de depuración
    );
  }
}
