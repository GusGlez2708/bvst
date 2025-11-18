// lib/screens/login_screen.dart
import 'package:bvst/game/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // En una aplicación real, aquí iría la lógica de autenticación.
  // Por ahora, solo simularemos un acceso exitoso.
  void _authenticate() {
    // Simulamos un acceso exitoso después de un pequeño retraso
    // Solo si ambos campos tienen contenido (mínima validación)
    if (_usernameController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      AudioManager().playUiSfx(
        'start.mp3',
      ); // Usamos el sonido de inicio para el login

      // Navegación exitosa al menú principal
      Navigator.pushReplacementNamed(context, '/menu');
    } else {
      // Muestra una alerta simple de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa Usuario y Contraseña.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usa un fondo oscuro consistente
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF0D1B2A), Color(0xFF000000)],
            center: Alignment.center,
            radius: 0.8,
          ),
        ),
        child: Center(
          child: Container(
            width: 350, // Ancho fijo para el formulario
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF61E2FF).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ACCESO DE COMBATE',
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF61E2FF),
                  ),
                ),
                const SizedBox(height: 30),

                // Campo de Usuario
                _buildTextField(
                  controller: _usernameController,
                  labelText: 'USUARIO',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 20),

                // Campo de Contraseña
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'CONTRASEÑA',
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 40),

                // Botón de Login/Registro
                _buildStyledButton(
                  text: 'ACCEDER / REGISTRAR',
                  onTap: _authenticate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para campos de texto estilizados
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 12),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.orbitron(
          color: const Color(0xFF61E2FF),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF61E2FF)),
        filled: true,
        fillColor: const Color(0xFF2C3454).withOpacity(0.5),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF61E2FF), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF88D4F7), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 10.0,
        ),
      ),
    );
  }

  // Widget auxiliar para el botón de estilo retro
  Widget _buildStyledButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF4FA0E4),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF88D4F7), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.pressStart2p(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
