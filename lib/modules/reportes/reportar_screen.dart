import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medioambiente_rd/shared/services/api_service.dart';
import 'package:medioambiente_rd/data/database/database_helper.dart';
import 'dart:io';

class ReportarScreen extends StatefulWidget {
  const ReportarScreen({super.key});

  @override
  State<ReportarScreen> createState() => _ReportarScreenState();
}

class _ReportarScreenState extends State<ReportarScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  
  File? _foto;
  LatLng? _ubicacion;
  bool _isLoading = false;
  bool _obteniendoUbicacion = false;
  
  final List<String> _categorias = [
    'Deforestación',
    'Contaminación del agua',
    'Contaminación del aire',
    'Manejo de residuos',
    'Fauna en peligro',
    'Flora amenazada',
    'Construcción ilegal',
    'Otro'
  ];
  String _categoriaSeleccionada = 'Deforestación';

  final List<String> _urgencias = [
    'Baja',
    'Media',
    'Alta',
    'Emergencia'
  ];
  String _urgenciaSeleccionada = 'Media';

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionActual();
  }

  Future<void> _obtenerUbicacionActual() async {
    setState(() => _obteniendoUbicacion = true);
    
    try {
      // Solicitar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso de ubicación permanentemente denegado'),
          ),
        );
        return;
      }

      // Obtener ubicación
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _ubicacion = LatLng(position.latitude, position.longitude);
        _obteniendoUbicacion = false;
      });
    } catch (e) {
      setState(() => _obteniendoUbicacion = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error obteniendo ubicación: $e')),
      );
    }
  }

  Future<void> _tomarFoto() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Tomar foto'),
            onTap: () async {
              Navigator.pop(context);
              final XFile? foto = await _picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 80,
              );
              if (foto != null) {
                setState(() {
                  _foto = File(foto.path);
                });
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Elegir de la galería'),
            onTap: () async {
              Navigator.pop(context);
              final XFile? foto = await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );
              if (foto != null) {
                setState(() {
                  _foto = File(foto.path);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  String _convertirImagenABase64() {
    if (_foto == null) return '';
    final bytes = _foto!.readAsBytesSync();
    return base64Encode(bytes);
  }

  Future<void> _enviarReporte() async {
    if (!_formKey.currentState!.validate()) return;
    if (_ubicacion == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe obtener la ubicación')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiService();
      final response = await api.post('reportar', {
        'titulo': _tituloController.text,
        'descripcion': _descripcionController.text,
        'foto': _convertirImagenABase64(),
        'latitud': _ubicacion!.latitude,
        'longitud': _ubicacion!.longitude,
        'categoria': _categoriaSeleccionada,
        'urgencia': _urgenciaSeleccionada,
        'fecha': DateTime.now().toIso8601String(),
      });

      if (response['exito'] == true) {
        // Guardar en SQLite
        final db = DatabaseHelper();
        await db.insertReporte({
          'codigo': response['codigo'] ?? 'N/A',
          'titulo': _tituloController.text,
          'descripcion': _descripcionController.text,
          'foto': _convertirImagenABase64(),
          'latitud': _ubicacion!.latitude,
          'longitud': _ubicacion!.longitude,
          'fecha': DateTime.now().toIso8601String(),
          'estado': 'Pendiente',
          'comentario': '',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['mensaje'] ?? 'Reporte enviado'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpiar formulario
        _formKey.currentState!.reset();
        setState(() {
          _foto = null;
          _categoriaSeleccionada = 'Deforestación';
          _urgenciaSeleccionada = 'Media';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['mensaje'] ?? 'Error al enviar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getUrgenciaColor(String urgencia) {
    switch (urgencia) {
      case 'Baja':
        return Colors.green;
      case 'Media':
        return Colors.orange;
      case 'Alta':
        return Colors.red;
      case 'Emergencia':
        return Colors.red.shade900;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Daño Ambiental'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante5.jpg'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '📝 Reporte de Daño Ambiental',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Ayúdanos a proteger el medio ambiente reportando situaciones que requieren atención',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 25),
              // Categoría
              const Text(
                'Categoría del problema*',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _categoriaSeleccionada,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _categorias.map((String categoria) {
                  return DropdownMenuItem<String>(
                    value: categoria,
                    child: Text(categoria),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Título
              const Text(
                'Título del reporte*',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  hintText: 'Ej: Tala ilegal en Parque Central',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese un título';
                  }
                  if (value.length < 10) {
                    return 'Mínimo 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Descripción
              const Text(
                'Descripción detallada*',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  hintText: 'Describa el problema en detalle...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLines: 5,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese una descripción';
                  }
                  if (value.length < 30) {
                    return 'Mínimo 30 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // Urgencia
              const Text(
                'Nivel de urgencia*',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _urgencias.map((urgencia) {
                  return ChoiceChip(
                    label: Text(urgencia),
                    selected: _urgenciaSeleccionada == urgencia,
                    onSelected: (selected) {
                      setState(() {
                        _urgenciaSeleccionada = urgencia;
                      });
                    },
                    selectedColor: _getUrgenciaColor(urgencia),
                    labelStyle: TextStyle(
                      color: _urgenciaSeleccionada == urgencia
                          ? Colors.white
                          : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Foto
              const Text(
                '📸 Evidencia fotográfica',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _tomarFoto,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: _foto == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 50, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text(
                              'Tocar para tomar foto',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const Text(
                              'o seleccionar de la galería',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            _foto!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              if (_foto != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _tomarFoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Cambiar foto'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _foto = null;
                        });
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              // Ubicación
              const Text(
                '📍 Ubicación',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.green),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ubicación actual',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                if (_ubicacion != null)
                                  Text(
                                    'Lat: ${_ubicacion!.latitude.toStringAsFixed(6)}, '
                                    'Lon: ${_ubicacion!.longitude.toStringAsFixed(6)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          if (_obteniendoUbicacion)
                            const CircularProgressIndicator()
                          else
                            IconButton(
                              onPressed: _obtenerUbicacionActual,
                              icon: const Icon(Icons.refresh),
                              tooltip: 'Actualizar ubicación',
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _mostrarMapa();
                          },
                          icon: const Icon(Icons.map),
                          label: const Text('Ver en mapa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Información importante
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange),
                          SizedBox(width: 10),
                          Text(
                            'Información importante',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '• El reporte será revisado por personal del Ministerio',
                        style: TextStyle(fontSize: 14),
                      ),
                      const Text(
                        '• Recibirá un código de seguimiento',
                        style: TextStyle(fontSize: 14),
                      ),
                      const Text(
                        '• La ubicación exacta se mantiene confidencial',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.black, fontSize: 14),
                          children: [
                            TextSpan(text: 'Por su seguridad, '),
                            TextSpan(
                              text: 'NO se acerque a situaciones peligrosas',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: '. Tome fotos desde una distancia segura.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Botón de enviar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _enviarReporte,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Enviar Reporte',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  '* Campos obligatorios',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarMapa() {
    if (_ubicacion == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubicación del Reporte'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _ubicacion!,
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('reporte'),
                position: _ubicacion!,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueRed,
                ),
              ),
            },
            zoomControlsEnabled: true,
            myLocationEnabled: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}