import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import 'home_dashboard.dart'; // Adjust path if needed

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
  final String _baseUrl = "http://localhost:8080/haelin-app"; // 🔹 Update to your backend

  Future<void> _loginUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    print("🚀 ===== LOGIN PROCESS STARTED =====");

    if (email.isEmpty || password.isEmpty) {
      _showSnack("Please enter both email and password", Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    final client = http.Client();

    try {
      // 🔹 Step 1: Firebase Authentication
      print("1️⃣ Attempting Firebase authentication...");
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) throw Exception("Firebase user not found");

      print("✅ Firebase auth SUCCESSFUL!");
      print("   👤 UID: ${user.uid}");
      print("   📧 Email: ${user.email}");

      // 🔹 Step 2: Get fresh Firebase ID token
      print("2️⃣ Getting Firebase ID token...");
      final String? idToken = await user.getIdToken(true);

      if (idToken == null || idToken.isEmpty) {
        throw Exception("Failed to get Firebase token - token is null or empty");
      }

      print("✅ Token obtained successfully");
      print("   🔐 Token length: ${idToken.length}");

      // 🔹 Step 3: Send token to backend
      print("3️⃣ Sending token to backend...");
      final url = Uri.parse("$_baseUrl/user/login/patient");
      print("   🌐 URL: $url");

      final currentOrigin = Uri.base.origin;
      print("   📍 Current origin: $currentOrigin");

      final response = await client.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Origin": currentOrigin,
        },
        body: jsonEncode({"idToken": idToken}),
      ).timeout(const Duration(seconds: 10));

      print("📡 Backend Response:");
      print("   📊 Status Code: ${response.statusCode}");
      print("   📄 Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print("✅ Backend login SUCCESSFUL!");
        String username = data["user"]?["userName"] ??
            user.displayName ??
            user.email?.split('@').first ??
            "User";

        _showSnack("Login successful", Colors.green);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeDashboard(username: username)),
        );
      } else {
        print("❌ Backend error: ${response.statusCode}");
        _showSnack("Login failed: ${response.body}", Colors.redAccent);
      }
    } on FirebaseAuthException catch (e) {
      print("🔴 Firebase Auth Exception: ${e.code}");
      String msg;
      switch (e.code) {
        case 'invalid-email':
          msg = "Invalid email address";
          break;
        case 'user-disabled':
          msg = "This account has been disabled";
          break;
        case 'user-not-found':
          msg = "No user found with this email";
          break;
        case 'wrong-password':
          msg = "Incorrect password";
          break;
        default:
          msg = "Authentication failed: ${e.message}";
      }
      _showSnack(msg, Colors.redAccent);
    } on SocketException {
      print("🔴 SocketException - Network error");
      _showSnack("Network error: Cannot reach backend", Colors.redAccent);
    } on TimeoutException {
      print("🔴 TimeoutException - Backend not responding");
      _showSnack("Connection timeout", Colors.orangeAccent);
    } catch (e) {
      print("🔴 Unexpected error: $e");
      _showSnack("Unexpected error: $e", Colors.redAccent);
    } finally {
      client.close();
      setState(() => _isLoading = false);
      print("🏁 ===== LOGIN PROCESS COMPLETED =====");
    }
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
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
              const Icon(Icons.local_hospital, size: 80, color: Colors.blueAccent),
              const SizedBox(height: 20),
              const Text(
                "Haelin App Login",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 40),

              // Email field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              // Login button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _loginUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "Backend: $_baseUrl",
                style: const TextStyle(fontSize: 10, color: Colors.grey),
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
