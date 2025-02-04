import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:lds/View/ZatcaDashboard.dart';
import 'package:lds/l10n/app_localizations.dart';  // Import the localization class

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

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> loginUser() async {
    setState(() {
      _isLoading = true;
    });

    // Prepare the request body
    final Map<String, String> requestBody = {
      'Username': _emailController.text,
      'Password': _passwordController.text,
      'grant_type': 'password', // Set grant_type as per the API requirements
    };

    // Set the headers
    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    // API endpoint
    const url = 'https://posapi.lakhanisolution.com/Login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: requestBody,
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['AccessToken'] != null) {
          final token = responseData['AccessToken'];
          final email = responseData['Email'];
          final CompanyId = responseData['Company_Id'];
          final username = responseData['User_Name'];
          final userType = responseData['User_Type'];
          final status = responseData['Status'];

          await secureStorage.write(key: 'AccessToken', value: token);
          await secureStorage.write(key: 'username', value: _emailController.text);
          await secureStorage.write(key: 'Email', value: email);
          await secureStorage.write(key: 'Company_Id', value: CompanyId.toString());
          await secureStorage.write(key: 'User_Name', value: username);
          await secureStorage.write(key: 'User_Type', value: userType);
          await secureStorage.write(key: 'Status', value: status);

          await _saveCredentials();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context, 'invalid_credentials'))),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context, 'error_occurred')} ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context, 'error_occurred')} $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCredentials() async {
    if (_rememberMe) {
      await secureStorage.write(key: 'email', value: _emailController.text);
      await secureStorage.write(key: 'password', value: _passwordController.text);
    } else {
      await secureStorage.delete(key: 'email');
      await secureStorage.delete(key: 'password');
    }
  }

  Future<void> _loadCredentials() async {
    String? email = await secureStorage.read(key: 'email');
    String? password = await secureStorage.read(key: 'password');

    if (email != null && password != null) {
      setState(() {
        _emailController.text = email;
        _passwordController.text = password;
        _rememberMe = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
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
                        'assets/logo.png',
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
              Padding(
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
                        AppLocalizations.of(context, 'email'),
                        style: GoogleFonts.lato(color: Colors.black87, fontSize: 16),
                      ),
                      TextFormField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context, 'enter_email'),
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
                        AppLocalizations.of(context, 'password'),
                        style: GoogleFonts.lato(color: Colors.black87, fontSize: 16),
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context, 'enter_password'),
                          hintStyle: const TextStyle(color: Colors.grey),
                          prefixIcon: const Icon(Icons.lock, color: Colors.black),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.black,
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
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
                          Text(AppLocalizations.of(context, 'remember_me')),
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
                              : Text(
                            AppLocalizations.of(context, 'login'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
