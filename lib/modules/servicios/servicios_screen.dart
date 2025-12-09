import 'package:flutter/material.dart';
import 'package:medioambiente_rd/shared/services/api_service.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  List<Map<String, dynamic>> servicios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarServicios();
  }

  Future<void> _cargarServicios() async {
    try {
      final api = ApiService();
      final response = await api.get('servicios');
      
      if (response['exito'] == true) {
        setState(() {
          servicios = List<Map<String, dynamic>>.from(response['datos']);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Datos de ejemplo si falla la API
      servicios = [
        {
          'id': '1',
          'nombre': 'Permisos Ambientales',
          'descripcion': 'Evaluación y emisión de permisos para actividades que impacten el medio ambiente',
          'icono': 'permisos',
          'contacto': 'permisos@medioambiente.gob.do',
          'requisitos': ['Formulario de solicitud', 'Estudio de impacto ambiental', 'Plan de mitigación']
        },
        {
          'id': '2',
          'nombre': 'Educación Ambiental',
          'descripcion': 'Programas educativos para escuelas, comunidades y empresas',
          'icono': 'educacion',
          'contacto': 'educacion@medioambiente.gob.do',
          'requisitos': ['Solicitud formal', 'Grupo mínimo de 20 personas']
        },
        {
          'id': '3',
          'nombre': 'Denuncias Ambientales',
          'descripcion': 'Recepción y seguimiento de denuncias por daños ambientales',
          'icono': 'denuncias',
          'contacto': 'denuncias@medioambiente.gob.do',
          'requisitos': ['Descripción detallada', 'Ubicación precisa', 'Evidencia fotográfica']
        },
        {
          'id': '4',
          'nombre': 'Certificaciones Verdes',
          'descripcion': 'Certificación de productos y procesos amigables con el ambiente',
          'icono': 'certificaciones',
          'contacto': 'certificaciones@medioambiente.gob.do',
          'requisitos': ['Auditoría ambiental', 'Cumplimiento de normas', 'Plan de sostenibilidad']
        },
        {
          'id': '5',
          'nombre': 'Asesoría Técnica',
          'descripcion': 'Asesoramiento en manejo de recursos naturales y conservación',
          'icono': 'asesoria',
          'contacto': 'asesoria@medioambiente.gob.do',
          'requisitos': ['Cita previa', 'Documentación del proyecto']
        },
      ];
    }
  }

  IconData _getIcon(String icono) {
    switch (icono) {
      case 'permisos':
        return Icons.assignment_turned_in;
      case 'educacion':
        return Icons.school;
      case 'denuncias':
        return Icons.report;
      case 'certificaciones':
        return Icons.verified;
      case 'asesoria':
        return Icons.support_agent;
      default:
        return Icons.business_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servicios'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante3.jpg'),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: servicios.length,
              itemBuilder: (context, index) {
                final servicio = servicios[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  child: ExpansionTile(
                    leading: Icon(_getIcon(servicio['icono']), 
                        color: Colors.green, size: 30),
                    title: Text(
                      servicio['nombre'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              servicio['descripcion'],
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (servicio['requisitos'] != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Requisitos:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...List<Widget>.generate(
                                    servicio['requisitos'].length,
                                    (i) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.check_circle,
                                              size: 16, color: Colors.green),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(servicio['requisitos'][i]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(Icons.email, size: 20, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  'Contacto: ${servicio['contacto']}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Acción para solicitar servicio
                                  _solicitarServicio(servicio);
                                },
                                icon: const Icon(Icons.send),
                                label: const Text('Solicitar Servicio'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _solicitarServicio(Map<String, dynamic> servicio) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Solicitar ${servicio['nombre']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Complete el formulario para solicitar este servicio:'),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre completo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Descripción de la solicitud',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Solicitud de ${servicio['nombre']} enviada'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Enviar Solicitud'),
          ),
        ],
      ),
    );
  }
}