class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    
    return null;
  }

  static String? validateCedula(String? value) {
    if (value == null || value.isEmpty) {
      return 'La cédula es requerida';
    }
    
    if (value.length != 11) {
      return 'Cédula debe tener 11 dígitos';
    }
    
    // Validar formato de cédula dominicana
    if (!RegExp(r'^\d{11}$').hasMatch(value)) {
      return 'Cédula inválida';
    }
    
    return null;
  }

  static String? validateTelefono(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }
    
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Teléfono inválido (10 dígitos)';
    }
    
    return null;
  }

  static String? validateNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (value.length < 3) {
      return 'Mínimo 3 caracteres';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    
    return null;
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    
    return null;
  }

  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName no debe exceder $maxLength caracteres';
    }
    
    return null;
  }
}