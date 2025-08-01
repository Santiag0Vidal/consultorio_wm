// lib/models/user.dart
// Modelo de datos para un Usuario
class User {
  int? id; // ID único del usuario (opcional para cuando aún no está en la DB)
  String name;
  String address;
  String dni;
  String gender;
  int age;
  String primarySport;
  String dominantHemisphere;
  String phone;
  double weight;
  double height;
  String primaryOccupation;

  // Constructor de la clase User
  User({
    this.id,
    required this.name,
    required this.address,
    required this.dni,
    required this.gender,
    required this.age,
    required this.primarySport,
    required this.dominantHemisphere,
    required this.phone,
    required this.weight,
    required this.height,
    required this.primaryOccupation,
  });

  // Convierte un objeto User a un Map para insertarlo en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'dni': dni,
      'gender': gender,
      'age': age,
      'primarySport': primarySport,
      'dominantHemisphere': dominantHemisphere,
      'phone': phone,
      'weight': weight,
      'height': height,
      'primaryOccupation': primaryOccupation,
    };
  }

  // Crea un objeto User desde un Map (obtenido de la base de datos)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      dni: map['dni'],
      gender: map['gender'],
      age: map['age'],
      primarySport: map['primarySport'],
      dominantHemisphere: map['dominantHemisphere'],
      phone: map['phone'],
      weight: map['weight'],
      height: map['height'],
      primaryOccupation: map['primaryOccupation'],
    );
  }
}
