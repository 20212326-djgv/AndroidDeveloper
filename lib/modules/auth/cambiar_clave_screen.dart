import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medioambiente_rd/shared/services/auth_service.dart';

class CambiarClaveScreen extends StatefulWidget {
  const CambiarClaveScreen({super.key});

  @override
  State<CambiarClaveScreen> createState() => _CambiarClaveScreenState();
}

class _CambiarClaveScreenState extends State<CambiarClaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _claveActualController = TextEditingController();
  final TextEditingController _nuevaClaveController = TextEditingController();
  final TextEditingController _confirmarClaveController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscureClaveActual = true;
  bool _obscureNuevaClave = true;
  bool _obscureConfirmarClave = true;
  
  // Variables para validar requisitos
  bool _tieneLongitudMinima = false;
  bool _tieneMayuscula = false;
  bool _tieneNumero = false;
  bool _tieneCaracterEspecial = false;
  
  @override
  void initState() {
    super.initState();
    // Escuchar cambios en el campo de nueva clave
    _nuevaClaveController.addListener(_validarRequisitos);
  }
  
  void _validarRequisitos() {
    final clave = _nuevaClaveController.text;
    
    setState(() {
      _tieneLongitudMinima = clave.length >= 8;
      _tieneMayuscula = clave.contains(RegExp(r'[A-Z]'));
      _tieneNumero = clave.contains(RegExp(r'[0-9]'));
      _tieneCaracterEspecial = clave.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }
  
  bool get _requisitosCumplidos {
    return _tieneLongitudMinima && 
           _tieneMayuscula && 
           _tieneNumero && 
           _tieneCaracterEspecial;
  }
  
  double get _fortalezaClave {
    int requisitosCumplidos = 0;
    if (_tieneLongitudMinima) requisitosCumplidos++;
    if (_tieneMayuscula) requisitosCumplidos++;
    if (_tieneNumero) requisitosCumplidos++;
    if (_tieneCaracterEspecial) requisitosCumplidos++;
    
    return requisitosCumplidos / 4;
  }
  
  String get _nivelFortaleza {
    if (_fortalezaClave == 0) return 'Débil';
    if (_fortalezaClave < 0.5) return 'Débil';
    if (_fortalezaClave < 0.75) return 'Media';
    if (_fortalezaClave < 1) return 'Fuerte';
    return 'Muy Fuerte';
  }
  
  Color get _colorFortaleza {
    if (_fortalezaClave == 0) return Colors.grey;
    if (_fortalezaClave < 0.5) return Colors.red;
    if (_fortalezaClave < 0.75) return Colors.orange;
    if (_fortalezaClave < 1) return Colors.blue;
    return Colors.green;
  }
  
  Future<void> _cambiarClave() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_nuevaClaveController.text != _confirmarClaveController.text) {
      _mostrarError('Las contraseñas no coinciden');
      return;
    }
    
    if (!_requisitosCumplidos) {
      _mostrarError('La nueva contraseña no cumple con todos los requisitos de seguridad');
      return;
    }
    
    setState(() => _isLoading = true);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final result = await authService.cambiarClave(
      claveActual: _claveActualController.text,
      nuevaClave: _nuevaClaveController.text,
    );
    
    setState(() => _isLoading = false);
    
    if (result['exito'] == true) {
      _mostrarExito(result['mensaje'] ?? 'Contraseña cambiada exitosamente');
      _limpiarFormulario();
    } else {
      _mostrarError(result['mensaje'] ?? 'Error al cambiar la contraseña');
    }
  }
  
  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    _claveActualController.clear();
    _nuevaClaveController.clear();
    _confirmarClaveController.clear();
    
    setState(() {
      _tieneLongitudMinima = false;
      _tieneMayuscula = false;
      _tieneNumero = false;
      _tieneCaracterEspecial = false;
    });
  }
  
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  void _mostrarExito(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Éxito!'),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Volver a la pantalla anterior
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
  
  void _mostrarRequisitos() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Requisitos de Seguridad',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildRequisitoItem(
              'Mínimo 8 caracteres',
              _tieneLongitudMinima,
            ),
            _buildRequisitoItem(
              'Al menos una letra mayúscula',
              _tieneMayuscula,
            ),
            _buildRequisitoItem(
              'Al menos un número',
              _tieneNumero,
            ),
            _buildRequisitoItem(
              'Al menos un carácter especial (!@#\$%^&*)',
              _tieneCaracterEspecial,
            ),
            const SizedBox(height: 20),
            const Text(
              'Ejemplos de contraseñas seguras:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('• Am1g0@2025'),
            const Text('• Verde#2025RD'),
            const Text('• M3d!0Amb!ente'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRequisitoItem(String texto, bool cumplido) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            cumplido ? Icons.check_circle : Icons.circle,
            size: 20,
            color: cumplido ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 10),
          Text(
            texto,
            style: TextStyle(
              color: cumplido ? Colors.green : Colors.grey,
              decoration: cumplido ? null : TextDecoration.lineThrough,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante1.jpg'),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _mostrarRequisitos,
            tooltip: 'Ver requisitos de seguridad',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono y título
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: const Icon(
                        Icons.lock_reset,
                        size: 40,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Cambiar Contraseña',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Actualice su contraseña para mantener su cuenta segura',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Contraseña actual
              const Text(
                'Contraseña actual',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _claveActualController,
                decoration: InputDecoration(
                  hintText: 'Ingrese su contraseña actual',
                  prefixIcon: const Icon(Icons.lock_clock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureClaveActual
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureClaveActual = !_obscureClaveActual;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                obscureText: _obscureClaveActual,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese su contraseña actual';
                  }
                  if (value.length < 6) {
                    return 'Mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 20),
              
              // Nueva contraseña
              const Text(
                'Nueva contraseña',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nuevaClaveController,
                decoration: InputDecoration(
                  hintText: 'Ingrese nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNuevaClave
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNuevaClave = !_obscureNuevaClave;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                obscureText: _obscureNuevaClave,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingrese la nueva contraseña';
                  }
                  return null;
                },
              ),
              
              // Indicador de fortaleza
              if (_nuevaClaveController.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Fortaleza: $_nivelFortaleza',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _colorFortaleza,
                          ),
                        ),
                        Text(
                          '${(_fortalezaClave * 100).toInt()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _colorFortaleza,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    LinearProgressIndicator(
                      value: _fortalezaClave,
                      backgroundColor: Colors.grey[200],
                      color: _colorFortaleza,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ],
              
              const SizedBox(height: 20),
              
              // Confirmar nueva contraseña
              const Text(
                'Confirmar nueva contraseña',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmarClaveController,
                decoration: InputDecoration(
                  hintText: 'Confirme la nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_reset),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmarClave
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmarClave = !_obscureConfirmarClave;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                obscureText: _obscureConfirmarClave,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Confirme la nueva contraseña';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 30),
              
              // Tarjeta de requisitos
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.security, color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            'Requisitos de seguridad',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      _buildRequisitoCardItem(
                        'Mínimo 8 caracteres',
                        _tieneLongitudMinima,
                      ),
                      _buildRequisitoCardItem(
                        'Al menos una mayúscula',
                        _tieneMayuscula,
                      ),
                      _buildRequisitoCardItem(
                        'Al menos un número',
                        _tieneNumero,
                      ),
                      _buildRequisitoCardItem(
                        'Al menos un carácter especial',
                        _tieneCaracterEspecial,
                      ),
                      if (_requisitosCumplidos) ...[
                        const SizedBox(height: 10),
                        const Text(
                          '✓ Todos los requisitos cumplidos',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Botón de cambiar contraseña
              SizedBox(
                width: double.infinity,
                height: 50,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _cambiarClave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Cambiar Contraseña',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
              ),
              
              const SizedBox(height: 15),
              
              // Enlace para volver
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar y volver'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildRequisitoCardItem(String texto, bool cumplido) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            cumplido ? Icons.check_circle : Icons.circle,
            size: 20,
            color: cumplido ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                color: cumplido ? Colors.green : Colors.grey,
                decoration: cumplido ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _claveActualController.dispose();
    _nuevaClaveController.dispose();
    _confirmarClaveController.dispose();
    super.dispose();
  }
}