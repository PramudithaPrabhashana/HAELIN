import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'home_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Helper method to get the correct base URL based on platform
  String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8080/haelin-app';
    } else {
      return 'http://192.168.1.100:8080/haelin-app'; // Make sure to add /haelin-app here too
    }
  }

 Future<void> _loginUser() async {
  // Validate email and password
  if (_emailController.text.trim().isEmpty ||
      _passwordController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please enter both email and password")),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    // 1️⃣ Login with Firebase Authentication
    print('🟡 Step 1: Starting Firebase authentication...');
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
    print('✅ Step 1: Firebase authentication successful');

    // 2️⃣ Get the ID token from Firebase
    print('🟡 Step 2: Getting Firebase ID token...');
    String? idToken = await userCredential.user?.getIdToken();
    if (idToken == null) throw Exception("Failed to get Firebase ID token");
    print('✅ Step 2: Got Firebase ID token');

    // 3️⃣ Send token to backend for verification
    final String baseUrl = getBaseUrl();
    final String loginUrl = '$baseUrl/user/login/patient';
    
    print('🟡 Step 3: Preparing backend request...');
    print('🌐 URL: $loginUrl');
    print('📧 User Email: ${userCredential.user?.email}');

    // 4️⃣ Send request to backend
    print('🟡 Step 4: Sending request to backend...');
    var response = await http.post(
      Uri.parse(loginUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "idToken": idToken
      }),
    );

    print('✅ Step 4: Backend responded with status: ${response.statusCode}');
    print('📄 Response body: ${response.body}');

    // 5️⃣ Handle response
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print('✅ Login successful');
      print('👤 User data: ${data["user"]}');
      
      // Extract username from response
      String username = "User";
      if (data["user"] != null && data["user"]["userName"] != null) {
        username = data["user"]["userName"];
      } else if (userCredential.user?.displayName != null) {
        username = userCredential.user!.displayName!;
      } else if (userCredential.user?.email != null) {
        username = userCredential.user!.email!;
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login Successful")),
      );

      // ✅ Navigate to HomeDashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeDashboard(
            username: username,
          ),
        ),
      );
    } else {
      print('❌ Backend error: ${response.statusCode}');
      // Don't show "Access Denied" message for non-admin users
      if (response.statusCode != 403) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${response.body}")),
        );
      }
    }
  } catch (e) {
    print('❌ Exception: $e');
    print('❌ Exception type: ${e.runtimeType}');
    
    // Handle specific errors using if-else instead of multiple catch blocks
    if (e is FirebaseAuthException) {
      String errorMessage = "Login failed";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This account has been disabled";
      } else if (e.code == 'too-many-requests') {
        errorMessage = "Too many attempts. Try again later";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } else if (e is http.ClientException) {
      // Handle HTTP client errors (network issues, etc.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Network error: Cannot connect to server")),
      );
    } else if (e is FormatException) {
      // Handle JSON parsing errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data format error")),
      );
    } else {
      // Handle all other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔹 App Logo
              Image.asset('assets/app_logo.png', width: 100, height: 100),
              const SizedBox(height: 20),

              const Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),

              // 🔹 Email Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 🔹 Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF286BB5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Log In',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Create Account Link
              GestureDetector(
                onTap: _isLoading
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/signup');
                      },
                child: const Text.rich(
                  TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Create one',
                        style: TextStyle(
                          color: Color(0xFF286BB5),
                          fontWeight: FontWeight.bold,
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}