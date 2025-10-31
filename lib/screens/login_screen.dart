import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/screens/main_screen.dart';
import 'package:my_app/services/login_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _resetEmailController = TextEditingController();
  final LoginService _loginService = LoginService();
  Color _colorPage = Colors.blue;

  bool _isLoading = false;
  bool _isLogin = true; // Toggle between login and register

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        // Login
        final user = await _loginService.loginWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (user != null) {
          _emailController.clear();
          _passwordController.clear(); 
          _navigateToDashboard();
        }

      } else {
        // Register
        await _loginService.registerWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Don't auto-login after registration
        await FirebaseAuth.instance.signOut();

         // Exit if the widget is gone
        if (!mounted) return;

        // ✅ FIXED showDialog syntax
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Verify Your Email 📧'),
            content: Text(
              'A verification link has been sent to ${_emailController.text.trim()}. '
              'Please verify your email before logging in.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();

                  _toggleFormMode(); // switch to login mode
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
        // Exit if the widget is gone
        if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Firebase error')));
    } catch (e) {
        // Exit if the widget is gone
        if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showResetPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: _resetEmailController,
            decoration: const InputDecoration(labelText: 'Enter your email'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await _loginService.sendPasswordResetEmail(
                    _resetEmailController.text.trim(),
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password reset email sent')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDashboard() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  void _setColorPage() {
    if (_isLogin) {
      _colorPage = Colors.blue;
    } else {
      _colorPage = Colors.green;
    }
  }

  void _toggleFormMode() {
    setState(() => _isLogin = !_isLogin);
    _setColorPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Welcome Back 👋' : 'Create Your Account ✨'),
        backgroundColor: _colorPage,
      ),
      body: Align(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isLogin
                      ? 'Welcome back! Please login to continue.'
                      : 'Create a new account to get started.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, // card background
                    borderRadius: BorderRadius.circular(16), // rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12, // shadow color
                        blurRadius: 10, // blur intensity
                        offset: const Offset(0, 5), // vertical offset
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _colorPage,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                  horizontal: 32,
                                ),
                              ),
                              child: Text(_isLogin ? 'Login' : 'Register'),
                            ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: _toggleFormMode,
                        child: Text(
                          _isLogin
                              ? 'Don\'t have an account? Register'
                              : 'Already have an account? Login',
                          style: TextStyle(color: _colorPage),
                        ),
                      ),
                      TextButton(
                        onPressed: _showResetPasswordDialog,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
