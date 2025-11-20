// lib/screens/login_screen.dart
import 'package:bvst/game/audio_manager.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleAuth() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Por favor, ingresa Usuario/Email y Contraseña.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // Detect if user entered an email or username
      final input = _usernameController.text.toLowerCase().trim();
      final email = input.contains('@')
          ? input // Use email directly if contains @
          : '$input@player.game'; // Otherwise add domain

      final password = _passwordController.text;

      // Extract username from email
      final username = input.contains('@') ? input.split('@')[0] : input;

      // Try to sign in first
      try {
        final signInResponse = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (signInResponse.user != null) {
          _onAuthSuccess();
        }
      } on AuthException catch (authError) {
        // If sign in fails, try to sign up
        if (authError.message.contains('Invalid login credentials') ||
            authError.message.contains('Email not confirmed')) {
          await _signUp(email, password, username);
        } else {
          throw authError;
        }
      }
    } catch (e) {
      _showError('Error de autenticación: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUp(String email, String password, String username) async {
    try {
      final supabase = Supabase.instance.client;

      // Sign up new user - trigger will auto-create users table entry
      final signUpResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (signUpResponse.user != null) {
        print('User registered: $username');
        _onAuthSuccess();
      }
    } catch (e) {
      throw Exception('Error en registro: ${e.toString()}');
    }
  }

  void _onAuthSuccess() {
    AudioManager().playUiSfx('start.mp3');
    Navigator.pushReplacementNamed(context, '/menu');
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            width: 350,
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

                // Campo de Usuario/Email
                _buildTextField(
                  controller: _usernameController,
                  labelText: 'USUARIO o EMAIL',
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
                _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF61E2FF))
                    : _buildStyledButton(
                        text: 'ACCEDER / REGISTRAR',
                        onTap: _handleAuth,
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
