class AreaProtegida {
  final String id;
  final String nombre;
  final String descripcion;
  final String imagen;
  final double latitud;
  final double longitud;
  final String tipo;
  final double extension;
  final String provincia;

  AreaProtegida({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.imagen,
    required this.latitud,
    required this.longitud,
    required this.tipo,
    required this.extension,
    required this.provincia,
  });

  factory AreaProtegida.fromJson(Map<String, dynamic> json) {
    return AreaProtegida(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      imagen: json['imagen'] ?? '',
      latitud: double.tryParse(json['latitud'].toString()) ?? 0.0,
      longitud: double.tryParse(json['longitud'].toString()) ?? 0.0,
      tipo: json['tipo'] ?? '',
      extension: double.tryParse(json['extension'].toString()) ?? 0.0,
      provincia: json['provincia'] ?? '',
    );
  }
}