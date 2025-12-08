import 'package:flutter/material.dart';
import 'package:medioambiente_rd/shared/services/api_service.dart';
import 'package:medioambiente_rd/data/database/database_helper.dart';

class VoluntariadoScreen extends StatefulWidget {
  const VoluntariadoScreen({super.key});

  @override
  State<VoluntariadoScreen> createState() => _VoluntariadoScreenState();
}

class _VoluntariadoScreenState extends State<VoluntariadoScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'cedula': TextEditingController(),
    'nombre': TextEditingController(),
    'email': TextEditingController(),
    'password': TextEditingController(),
    'telefono': TextEditingController(),
  };
  bool _isLoading = false;
  bool _aceptaTerminos = false;
  bool _obscurePassword = true;

  final List<Map<String, dynamic>> programas = [
    {
      'id': '1',
      'nombre': 'Guardianes del Ambiente',
      'descripcion': 'Programa de monitoreo y vigilancia ambiental',
      'requisitos': [
        'Mayor de 18 años',
        'Disponibilidad fines de semana',
        'Conocimientos básicos de ecología'
      ],
      'horario': 'Sábados 8:00 AM - 12:00 PM',
      'lugar': 'Áreas protegidas cercanas',
      'beneficios': ['Certificado', 'Kit de voluntario', 'Transporte']
    },
    {
      'id': '2',
      'nombre': 'Educadores Ambientales',
      'descripcion': 'Programa de educación en escuelas y comunidades',
      'requisitos': [
        'Habilidad para hablar en público',
        'Paciencia con niños',
        'Creatividad'
      ],
      'horario': 'Flexible',
      'lugar': 'Escuelas y centros comunitarios',
      'beneficios': ['Capacitación', 'Material educativo', 'Reconocimiento']
    },
    {
      'id': '3',
      'nombre': 'Brigadas de Reforestación',
      'descripcion': 'Plantación y cuidado de árboles en áreas degradadas',
      'requisitos': [
        'Buen estado físico',
        'Tolerancia al sol',
        'Trabajo en equipo'
      ],
      'horario': 'Domingos 7:00 AM - 11:00 AM',
      'lugar': 'Diferentes zonas del país',
      'beneficios': ['Uniforme', 'Herramientas', 'Refrigerio']
    },
  ];

  final List<String> _requisitosGenerales = [
    'Ser mayor de 16 años (con autorización de padres si es menor)',
    'Tener interés en temas ambientales',
    'Disponer de al menos 4 horas semanales',
    'Comprometerse por mínimo 3 meses',
    'No tener antecedentes penales',
    'Participar en la capacitación inicial',
  ];

  void _mostrarProgramaDetalle(Map<String, dynamic> programa) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        maxChildSize: 1.0,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Programa de Voluntariado',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          programa['nombre'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          programa['descripcion'],
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '📋 Requisitos Específicos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...programa['requisitos'].map((requisito) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 20, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(child: Text(requisito)),
                        ],
                      ),
                    )),
                const SizedBox(height: 20),
                const Text(
                  '📅 Horario y Lugar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.green),
                  title: const Text('Horario'),
                  subtitle: Text(programa['horario']),
                ),
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.green),
                  title: const Text('Lugar'),
                  subtitle: Text(programa['lugar']),
                ),
                const SizedBox(height: 20),
                const Text(
                  '🎁 Beneficios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: programa['beneficios']
                      .map((beneficio) => Chip(
                            label: Text(beneficio),
                            backgroundColor: Colors.green.shade100,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _scrollToForm();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text('Quiero Participar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToForm() {
    Scrollable.ensureVisible(
      _formKey.currentContext!,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _enviarSolicitud() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe aceptar los términos y condiciones'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final api = ApiService();
      final response = await api.post('voluntariado', {
        'cedula': _controllers['cedula']!.text,
        'nombre': _controllers['nombre']!.text,
        'email': _controllers['email']!.text,
        'password': _controllers['password']!.text,
        'telefono': _controllers['telefono']!.text,
      });

      if (response['exito'] == true) {
        // Guardar en SQLite
        final db = DatabaseHelper();
        await db.insertUsuario({
          'cedula': _controllers['cedula']!.text,
          'nombre': _controllers['nombre']!.text,
          'email': _controllers['email']!.text,
          'password': _controllers['password']!.text,
          'telefono': _controllers['telefono']!.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['mensaje'] ?? 'Solicitud enviada'),
            backgroundColor: Colors.green,
          ),
        );

        // Limpiar formulario
        _formKey.currentState!.reset();
        setState(() => _aceptaTerminos = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voluntariado Ambiental'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante3.jpg'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(30),
              color: Colors.green.shade50,
              child: Column(
                children: [
                  const Icon(Icons.volunteer_activism,
                      size: 60, color: Colors.green),
                  const SizedBox(height: 20),
                  const Text(
                    '¡Sé Parte del Cambio!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Únete a nuestro equipo de voluntarios y contribuye '
                    'a proteger el medio ambiente de la República Dominicana',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Chip(
                    label: const Text('+2,500 Voluntarios Activos'),
                    backgroundColor: Colors.green,
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Programas disponibles
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Programas Disponibles',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: programas.length,
                itemBuilder: (context, index) {
                  final programa = programas[index];
                  return Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 16),
                    child: Card(
                      elevation: 4,
                      child: InkWell(
                        onTap: () => _mostrarProgramaDetalle(programa),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Programa ${programa['id']}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                programa['nombre'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                programa['descripcion'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                maxLines: 3,
                              ),
                              const Spacer(),
                              const Row(
                                children: [
                                  Text(
                                    'Ver detalles',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(Icons.arrow_forward,
                                      size: 16, color: Colors.green),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            // Requisitos generales
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📝 Requisitos Generales',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ..._requisitosGenerales.map((requisito) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.verified,
                                    size: 20, color: Colors.green),
                                const SizedBox(width: 10),
                                Expanded(child: Text(requisito)),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Formulario de registro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📋 Solicitud de Voluntariado',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Complete el formulario para ser voluntario',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 25),
                        // Cédula
                        TextFormField(
                          controller: _controllers['cedula'],
                          decoration: InputDecoration(
                            labelText: 'Cédula*',
                            prefixIcon: const Icon(Icons.badge),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su cédula';
                            }
                            if (value.length != 11) {
                              return 'Cédula inválida';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // Nombre
                        TextFormField(
                          controller: _controllers['nombre'],
                          decoration: InputDecoration(
                            labelText: 'Nombre y Apellido*',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su nombre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // Email
                        TextFormField(
                          controller: _controllers['email'],
                          decoration: InputDecoration(
                            labelText: 'Correo Electrónico*',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su email';
                            }
                            if (!value.contains('@')) {
                              return 'Email inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // Contraseña
                        TextFormField(
                          controller: _controllers['password'],
                          decoration: InputDecoration(
                            labelText: 'Contraseña*',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su contraseña';
                            }
                            if (value.length < 6) {
                              return 'Mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // Teléfono
                        TextFormField(
                          controller: _controllers['telefono'],
                          decoration: InputDecoration(
                            labelText: 'Teléfono*',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese su teléfono';
                            }
                            if (value.length != 10) {
                              return 'Teléfono inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Términos y condiciones
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _aceptaTerminos,
                              onChanged: (value) {
                                setState(() {
                                  _aceptaTerminos = value!;
                                });
                              },
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Acepto los términos y condiciones',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  InkWell(
                                    onTap: () {
                                      _mostrarTerminos();
                                    },
                                    child: const Text(
                                      'Leer términos y condiciones',
                                      style: TextStyle(
                                        color: Colors.green,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        // Botón de envío
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _enviarSolicitud,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Enviar Solicitud',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 15),
                        const Center(
                          child: Text(
                            '* Campos obligatorios',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // FAQ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '❓ Preguntas Frecuentes',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildFAQItem(
                        '¿Puedo ser voluntario si soy menor de edad?',
                        'Sí, mayores de 16 años con autorización de los padres.',
                      ),
                      _buildFAQItem(
                        '¿Cuánto tiempo debo comprometerme?',
                        'Mínimo 3 meses, con 4 horas semanales.',
                      ),
                      _buildFAQItem(
                        '¿Recibo algún beneficio?',
                        'Sí, certificado, capacitación y materiales.',
                      ),
                      _buildFAQItem(
                        '¿Puedo elegir el programa?',
                        'Sí, durante el proceso de inscripción.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String pregunta, String respuesta) {
    return ExpansionTile(
      title: Text(
        pregunta,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(respuesta),
        ),
      ],
    );
  }

  void _mostrarTerminos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Términos y Condiciones'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reglamento del Programa de Voluntariado Ambiental',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                _buildTerminoItem(
                  '1. Compromiso',
                  'El voluntario se compromete a cumplir con el horario y actividades asignadas.',
                ),
                _buildTerminoItem(
                  '2. Conducta',
                  'Se espera comportamiento profesional y respetuoso en todo momento.',
                ),
                _buildTerminoItem(
                  '3. Seguridad',
                  'El Ministerio proveerá equipo de seguridad necesario.',
                ),
                _buildTerminoItem(
                  '4. Confidencialidad',
                  'Información obtenida durante el voluntariado es confidencial.',
                ),
                _buildTerminoItem(
                  '5. Responsabilidad',
                  'El voluntario es responsable de sus pertenencias personales.',
                ),
                _buildTerminoItem(
                  '6. Terminación',
                  'El Ministerio puede terminar el voluntariado por incumplimiento.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminoItem(String titulo, String contenido) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(contenido),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}