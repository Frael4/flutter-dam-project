class Usuario {
  final String nombre;
  final int edad;
  final String correo;
  final String usuario;
  final String apellidos;
  final String contrasenia;

  Usuario({
    required this.nombre,
    required this.edad,
    required this.correo,
    required this.apellidos,
    required this.usuario,
    required this.contrasenia
  });

  // Método para convertir la instancia de la clase a un mapa
  Map<String, dynamic> toMap() {
    return {
      'usuario': usuario,
      'nombres': nombre,
      'apellidos' : apellidos,
      'edad': edad,
      'correo': correo,
      'contrasenia': contrasenia
    };
  }
}
