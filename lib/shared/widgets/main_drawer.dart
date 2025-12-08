import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medioambiente_rd/shared/services/auth_service.dart';

class MainDrawer extends StatelessWidget {
  final bool isLoggedIn;
  final Map<String, dynamic> userAvatars = {
    'Inicio': 'assets/avatars/estudiante1.jpg',
    'Sobre Nosotros': 'assets/avatars/estudiante2.jpg',
    'Servicios': 'assets/avatars/estudiante3.jpg',
    'Noticias': 'assets/avatars/estudiante4.jpg',
    'Videos': 'assets/avatars/estudiante5.jpg',
    'Áreas Protegidas': 'assets/avatars/estudiante6.jpg',
    'Mapa': 'assets/avatars/estudiante7.jpg',
    'Medidas': 'assets/avatars/estudiante1.jpg',
    'Equipo': 'assets/avatars/estudiante2.jpg',
    'Voluntariado': 'assets/avatars/estudiante3.jpg',
    'Normativas': 'assets/avatars/estudiante4.jpg',
    'Reportar Daño': 'assets/avatars/estudiante5.jpg',
    'Mis Reportes': 'assets/avatars/estudiante6.jpg',
    'Mapa Reportes': 'assets/avatars/estudiante7.jpg',
    'Cambiar Clave': 'assets/avatars/estudiante1.jpg',
    'Acerca de': 'assets/avatars/estudiante2.jpg',
  };

  MainDrawer({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.green, Colors.lightGreen],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(
                    isLoggedIn
                        ? 'assets/avatars/usuario.jpg'
                        : 'assets/logo_ministerio.png',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isLoggedIn ? 'Usuario Activo' : 'Visitante',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  isLoggedIn ? 'Bienvenido de vuelta' : 'Inicia sesión para más funciones',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          // Módulos públicos
          _buildDrawerItem(
            context,
            'Inicio',
            Icons.home,
            '/inicio',
            userAvatars['Inicio']!,
          ),
          _buildDrawerItem(
            context,
            'Sobre Nosotros',
            Icons.info,
            '/sobre-nosotros',
            userAvatars['Sobre Nosotros']!,
          ),
          _buildDrawerItem(
            context,
            'Servicios',
            Icons.business_center,
            '/servicios',
            userAvatars['Servicios']!,
          ),
          _buildDrawerItem(
            context,
            'Noticias',
            Icons.newspaper,
            '/noticias',
            userAvatars['Noticias']!,
          ),
          _buildDrawerItem(
            context,
            'Videos Educativos',
            Icons.video_library,
            '/videos',
            userAvatars['Videos']!,
          ),
          _buildDrawerItem(
            context,
            'Áreas Protegidas',
            Icons.park,
            '/areas-protegidas',
            userAvatars['Áreas Protegidas']!,
          ),
          _buildDrawerItem(
            context,
            'Mapa de Áreas',
            Icons.map,
            '/mapa-areas',
            userAvatars['Mapa']!,
          ),
          _buildDrawerItem(
            context,
            'Medidas Ambientales',
            Icons.eco,
            '/medidas',
            userAvatars['Medidas']!,
          ),
          _buildDrawerItem(
            context,
            'Equipo del Ministerio',
            Icons.people,
            '/equipo',
            userAvatars['Equipo']!,
          ),
          _buildDrawerItem(
            context,
            'Voluntariado',
            Icons.volunteer_activism,
            '/voluntariado',
            userAvatars['Voluntariado']!,
          ),
          
          if (isLoggedIn) ...[
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Módulos Privados',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            _buildDrawerItem(
              context,
              'Normativas',
              Icons.gavel,
              '/normativas',
              userAvatars['Normativas']!,
            ),
            _buildDrawerItem(
              context,
              'Reportar Daño',
              Icons.report,
              '/reportar',
              userAvatars['Reportar Daño']!,
            ),
            _buildDrawerItem(
              context,
              'Mis Reportes',
              Icons.list,
              '/mis-reportes',
              userAvatars['Mis Reportes']!,
            ),
            _buildDrawerItem(
              context,
              'Mapa de Reportes',
              Icons.map,
              '/mapa-reportes',
              userAvatars['Mapa Reportes']!,
            ),
            _buildDrawerItem(
              context,
              'Cambiar Contraseña',
              Icons.lock_reset,
              '/cambiar-clave',
              userAvatars['Cambiar Clave']!,
            ),
          ],
          
          const Divider(),
          _buildDrawerItem(
            context,
            'Acerca de',
            Icons.code,
            '/acerca-de',
            userAvatars['Acerca de']!,
          ),
          
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () {
                authService.logout();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          
          if (!isLoggedIn)
            ListTile(
              leading: const Icon(Icons.login, color: Colors.green),
              title: const Text('Iniciar Sesión'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String title,
    IconData icon,
    String route,
    String avatar,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green),
        ),
        child: CircleAvatar(
          backgroundImage: AssetImage(avatar),
          radius: 18,
        ),
      ),
      title: Text(title),
      trailing: Icon(icon, color: Colors.green),
      onTap: () {
        Navigator.pushReplacementNamed(context, route);
      },
    );
  }
}