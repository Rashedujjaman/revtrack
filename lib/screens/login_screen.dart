import 'package:flutter/material.dart';
import 'package:revtrack/screens/main_navigation_screen.dart';
import 'package:revtrack/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:game_sphere_bd/screens/home_screen.dart';
// import 'package:game_sphere_bd/screens/register_screen.dart';
// import 'package:game_sphere_bd/screens/reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    setState(() => _isLoading = true);

    if (_formKey.currentState!.validate()) {
      try {
        // 1. Firebase Authentication
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print(userCredential);
        // Handle successful login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const MainNavigationScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle Firebase authentication errors
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No user found for that email.')),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Wrong password provided for that user.')),
          );
        } else {
          print('Error: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to log in: $e')),
          );
        }
      } catch (e) {
        // Handle other errors (e.g., network issues)
        // print('Error: $e'); // Add this line to print the error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              'Something went wrong',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF62BDBD), Color(0xFF005555)],
                ),
              ),
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  // Center the form contents
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            //Logo of the app
                            const SizedBox(height: 50.0),
                            // Image.asset(
                            //   'assets/images/logo.png',
                            //   width: 400,
                            //   height: 100,
                            // ),
                            const SizedBox(height: 50.0),
                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                            TextFormField(
                              controller: _passwordController,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                              ),
                              obscureText: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 50.0),
                            SizedBox(
                              width: double
                                  .infinity, // Button width spans full width
                              child: ElevatedButton(
                                onPressed: () {
                                  // if (_formKey.currentState!.validate()) {
                                  //   _login();
                                  // }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10.0),
                            SizedBox(
                              width: double
                                  .infinity, // Button width spans full width
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return const RegisterScreen();
                                  }));
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  side: const BorderSide(
                                      color: Colors.amber, width: 1),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.amber),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            TextButton(
                              onPressed: () {
                                // TODO: Implement forgot password functionality
                                // Navigator.push(context,
                                //     MaterialPageRoute(builder: (context) {
                                //   return ResetPasswordScreen();
                                // }));
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            if (_isLoading)
                              const Center(
                                child: CircularProgressIndicator(
                                  color:
                                      Colors.white, //change the indicator color
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ))),
        ],
      ),
    );
  }
}
