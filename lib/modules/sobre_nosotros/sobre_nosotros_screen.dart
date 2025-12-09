import 'package:flutter/material.dart';

class SobreNosotrosScreen extends StatelessWidget {
  const SobreNosotrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre Nosotros'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante2.jpg'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video placeholder
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_circle_filled, size: 60, color: Colors.grey),
                    SizedBox(height: 10),
                    Text('Video institucional'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Historia
            const Text(
              'Nuestra Historia',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 10),
            
            const Text(
              'El Ministerio de Medio Ambiente y Recursos Naturales fue creado en el año 2000 '
              'con el objetivo de proteger y conservar los recursos naturales de la República Dominicana. '
              'Desde entonces, hemos trabajado incansablemente para implementar políticas ambientales '
              'que promuevan el desarrollo sostenible y la conservación de nuestra biodiversidad.',
              style: TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
            
            const SizedBox(height: 30),
            
            // Misión y Visión
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.flag, size: 50, color: Colors.green),
                          const SizedBox(height: 10),
                          const Text(
                            'Misión',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Proteger, conservar y restaurar los recursos naturales '
                            'para garantizar el desarrollo sostenible.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 10),
                
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.visibility, size: 50, color: Colors.green),
                          const SizedBox(height: 10),
                          const Text(
                            'Visión',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Ser líder en la gestión ambiental del Caribe, '
                            'promoviendo una cultura de conservación.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Valores
            const Text(
              'Nuestros Valores',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            
            const SizedBox(height: 10),
            
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildValueChip('Sostenibilidad', Icons.eco),
                _buildValueChip('Transparencia', Icons.visibility),
                _buildValueChip('Compromiso', Icons.handshake),
                _buildValueChip('Innovación', Icons.lightbulb),
                _buildValueChip('Equidad', Icons.balance),
                _buildValueChip('Excelencia', Icons.star),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Contacto
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contáctanos',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 15),
                    
                    const ListTile(
                      leading: Icon(Icons.location_on, color: Colors.green),
                      title: Text('Dirección'),
                      subtitle: Text('Av. Cayetano Germosén, Santo Domingo'),
                    ),
                    
                    const ListTile(
                      leading: Icon(Icons.phone, color: Colors.green),
                      title: Text('Teléfono'),
                      subtitle: Text('(809) 567-4300'),
                    ),
                    
                    const ListTile(
                      leading: Icon(Icons.email, color: Colors.green),
                      title: Text('Email'),
                      subtitle: Text('info@medioambiente.gob.do'),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    ElevatedButton(
                      onPressed: () {
                        // Abrir sitio web
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Visitar sitio web oficial'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueChip(String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 20),
      label: Text(text),
      backgroundColor: Colors.green.shade50,
    );
  }
}