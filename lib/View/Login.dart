import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:lds/API_Configuration/api.dart';
import 'package:lds/View/select_company.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  bool _isPasswordVisible = false;

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
    });

    // API URL
    const String apiUrl = 'https://6165-2400-adc1-484-8600-8110-9db-df88-2950.ngrok-free.app/Login';

    // Headers
    final headers = {
      'UserName': _emailController.text,
      'Password': _passwordController.text,
    };

    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}Login'), headers: headers);

      if (response.statusCode == 200) {
        secureStorage.write(key: 'username' , value: 'username');
        secureStorage.write(key: 'email' , value: 'email');

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CompanySelectionStaticPage()),
        );
      } else {
        // Display error if login fails
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please check your credentials.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred during login: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white60, Colors.blue],
          ),
        ),
        child: Column(
          children: [

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logo.png', // Your logo image path
                      height: 200,
                      width: 300,
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.cover,

                    ),
                    const SizedBox(height: 10),

                  ],
                ),
              ),
            ),

            // Login Form Section
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Field
                        Text(
                          "Email",
                          style: GoogleFonts.lato(color: Colors.black87, fontSize: 16),
                        ),
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: "Enter your email",
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.mail, color: Colors.black),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        Text(
                          "Password",
                          style: GoogleFonts.lato(color: Colors.black87, fontSize: 16),
                        ),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible, // Toggle visibility
                          style: const TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: "Enter your password",
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.lock, color: Colors.black),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible; // Toggle state
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Remember Me Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value!;
                                });
                              },
                              activeColor: Colors.blueAccent,
                            ),
                            const Text(
                              "Remember Me",
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Login Button
                        ElevatedButton(
                          onPressed: loginUser,
                          child: Container(

                            alignment: Alignment.center,
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "Log In",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Register Link
                        const Center(
                          child: Text(
                            "Don't have an account? REGISTER",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
