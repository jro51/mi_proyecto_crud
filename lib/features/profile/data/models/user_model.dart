import 'package:equatable/equatable.dart';

// Extender de Equatable permite que Flutter compare si dos objetos de tipo UserModel 
// son exactamente iguales por sus valores (id, username, etc.) y no por su referencia en memoria. 
// Esto optimiza los redibujados de la UI.
class UserModel extends Equatable {
  final int id;
  final String username;
  final int globalTrophies;

  const UserModel({
    required this.id,
    required this.username,
    required this.globalTrophies,
  });

  // Transforma el mapa (JSON) crudo que viene de Spring Boot en un objeto UserModel de Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      globalTrophies: json['globalTrophies'] as int,
    );
  }

  // Permite reconvertir el objeto a JSON por si en el futuro necesitas enviar el perfil actualizado al servidor.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'globalTrophies': globalTrophies,
    };
  }

  @override
  List<Object?> get props => [id, username, globalTrophies];
}