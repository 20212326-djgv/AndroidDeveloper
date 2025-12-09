import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AcercaDeScreen extends StatelessWidget {
  const AcercaDeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante1.jpg'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo de la app
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(75),
                border: Border.all(color: Colors.green, width: 3),
              ),
              child: const Icon(
                Icons.eco,
                size: 80,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Título
            const Text(
              'Ministerio de Medio Ambiente RD',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 5),
            
            const Text(
              'Versión 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 30),
            
            // Equipo de desarrollo
            const Text(
              'Desarrollado por:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Miembros del equipo (ajusta estos datos con tu equipo real)
            _buildTeamMember(
              'Juan Pérez',
              '2021-1234',
              '809-123-4567',
              '@juanperez',
              'assets/avatars/estudiante1.jpg',
              'Líder del Proyecto',
            ),
            
            _buildTeamMember(
              'María García',
              '2021-5678',
              '809-987-6543',
              '@mariagarcia',
              'assets/avatars/estudiante2.jpg',
              'Desarrolladora Frontend',
            ),
            
            _buildTeamMember(
              'Carlos Rodríguez',
              '2021-9012',
              '829-555-1234',
              '@carlosrod',
              'assets/avatars/estudiante3.jpg',
              'Desarrollador Backend',
            ),
            
            // Agrega más miembros según tu equipo...
            
            const SizedBox(height: 30),
            
            // Información de la institución
            const Text(
              'ITLA - Instituto Tecnológico de las Américas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const Text(
              'Tercer Trimestre 2025',
              style: TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 20),
            
            // Botones de contacto
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Contáctanos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 15),
                    
                    // Email
                    ListTile(
                      leading: const Icon(Icons.email, color: Colors.green),
                      title: const Text('Email del equipo'),
                      subtitle: const Text('equipo@itla.edu.do'),
                      onTap: () async {
                        final url = Uri.parse('mailto:equipo@itla.edu.do');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                    ),
                    
                    // Repositorio
                    ListTile(
                      leading: const Icon(Icons.code, color: Colors.green),
                      title: const Text('Repositorio GitHub'),
                      subtitle: const Text('github.com/tu-usuario/medioambiente-rd'),
                      onTap: () async {
                        final url = Uri.parse('https://github.com');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                    ),
                    
                    // Documentación
                    ListTile(
                      leading: const Icon(Icons.description, color: Colors.green),
                      title: const Text('Documentación'),
                      subtitle: const Text('Ver documentación técnica'),
                      onTap: () async {
                        final url = Uri.parse('https://flutter.dev');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Créditos
            const Text(
              '© 2025 - Todos los derechos reservados',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamMember(
    String nombre,
    String matricula,
    String telefono,
    String telegram,
    String foto,
    String rol,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            // Foto
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.green.shade100,
              backgroundImage: AssetImage(foto),
            ),
            
            const SizedBox(width: 15),
            
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  Text(
                    rol,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Botones de contacto
                  Row(
                    children: [
                      // Teléfono
                      IconButton(
                        icon: const Icon(Icons.phone, size: 20),
                        color: Colors.green,
                        onPressed: () async {
                          final url = Uri.parse('tel:$telefono');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                      ),
                      
                      // Telegram
                      IconButton(
                        icon: const Icon(Icons.telegram, size: 20),
                        color: Colors.blue,
                        onPressed: () async {
                          final username = telegram.startsWith('@') 
                              ? telegram.substring(1) 
                              : telegram;
                          final url = Uri.parse('https://t.me/$username');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                      ),
                      
                      // Email
                      IconButton(
                        icon: const Icon(Icons.email, size: 20),
                        color: Colors.red,
                        onPressed: () async {
                          final email = '$matricula@itla.edu.do';
                          final url = Uri.parse('mailto:$email');
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Matrícula
            Column(
              children: [
                const Text(
                  'Matrícula',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                
                Text(
                  matricula,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}