import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medioambiente_rd/shared/services/auth_service.dart';
import 'package:medioambiente_rd/shared/widgets/main_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  // Módulos públicos
  final List<Widget> _publicScreens = [
    const InicioScreen(),
    const SobreNosotrosScreen(),
    const ServiciosScreen(),
    const NoticiasScreen(),
    const VideosScreen(),
    const AreasProtegidasScreen(),
    const MapaAreasScreen(),
    const MedidasScreen(),
    const EquipoScreen(),
    const VoluntariadoScreen(),
    const AcercaDeScreen(),
  ];
  
  // Módulos privados (requieren login)
  final List<Widget> _privateScreens = [
    const NormativasScreen(),
    const ReportarScreen(),
    const MisReportesScreen(),
    const MapaReportesScreen(),
    const CambiarClaveScreen(),
  ];
  
  final List<String> _publicTitles = [
    'Inicio',
    'Sobre Nosotros',
    'Servicios',
    'Noticias',
    'Videos',
    'Áreas Protegidas',
    'Mapa de Áreas',
    'Medidas',
    'Equipo',
    'Voluntariado',
    'Acerca de',
  ];
  
  final List<String> _privateTitles = [
    'Normativas',
    'Reportar Daño',
    'Mis Reportes',
    'Mapa de Reportes',
    'Cambiar Clave',
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isLoggedIn = authService.isLoggedIn;

    // Combinar pantallas según estado de login
    final List<Widget> screens = isLoggedIn 
        ? [..._publicScreens, ..._privateScreens]
        : _publicScreens;
    
    final List<String> titles = isLoggedIn
        ? [..._publicTitles, ..._privateTitles]
        : _publicTitles;

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          if (!isLoggedIn)
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                // Mostrar perfil
              },
            ),
        ],
      ),
      drawer: MainDrawer(isLoggedIn: isLoggedIn),
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Sobre',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.business_center),
            label: 'Servicios',
          ),
          if (isLoggedIn)
            const BottomNavigationBarItem(
              icon: Icon(Icons.report),
              label: 'Reportes',
            ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Más',
          ),
        ],
      ),
    );
  }
}

// Placeholders para las pantallas (debes importar las reales)
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Inicio'));
}
class SobreNosotrosScreen extends StatelessWidget {
  const SobreNosotrosScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Sobre Nosotros'));
}
class ServiciosScreen extends StatelessWidget {
  const ServiciosScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Servicios'));
}
class NoticiasScreen extends StatelessWidget {
  const NoticiasScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Noticias'));
}
class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Videos'));
}
class AreasProtegidasScreen extends StatelessWidget {
  const AreasProtegidasScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Áreas'));
}
class MapaAreasScreen extends StatelessWidget {
  const MapaAreasScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Mapa Áreas'));
}
class MedidasScreen extends StatelessWidget {
  const MedidasScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Medidas'));
}
class EquipoScreen extends StatelessWidget {
  const EquipoScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Equipo'));
}
class VoluntariadoScreen extends StatelessWidget {
  const VoluntariadoScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Voluntariado'));
}
class AcercaDeScreen extends StatelessWidget {
  const AcercaDeScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Acerca de'));
}
class NormativasScreen extends StatelessWidget {
  const NormativasScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Normativas'));
}
class ReportarScreen extends StatelessWidget {
  const ReportarScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Reportar'));
}
class MisReportesScreen extends StatelessWidget {
  const MisReportesScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Mis Reportes'));
}
class MapaReportesScreen extends StatelessWidget {
  const MapaReportesScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Mapa Reportes'));
}
class CambiarClaveScreen extends StatelessWidget {
  const CambiarClaveScreen({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('Cambiar Clave'));
}