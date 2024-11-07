import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import '../database/database_helper.dart';
import 'dart:io';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _login() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Email and password are required");
      return;
    }

  try {
    // Authenticate user with encrypted password
    final user = await DatabaseHelper.instance.authenticateUser(email, password);

    if (user != null) {
      Fluttertoast.showToast(msg: "Login successful");

      // Check if the user box is available before storing the user ID
      if (Hive.isBoxOpen('user')) {
        await Hive.box('user').put('userId', user.id); // Store user info in Hive
      } else {
        Fluttertoast.showToast(msg: "Failed to store user information");
      }

      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Fluttertoast.showToast(msg: "Invalid email or password");
    }
  } catch (e) {
  String errorMsg = "An error occurred during login";

  // Handle specific errors based on the context of Flutter web
  if (e is FormatException) {
    errorMsg = "Data format error. Please contact support.";
  } else if (e is Exception) {
    errorMsg = "An unexpected error occurred. Please try again later.";
  } else {
    errorMsg = "An unknown error occurred. Please try again later.";
  }

  Fluttertoast.showToast(msg: errorMsg);
  print("Error during login: $e"); // Log the error for debugging
}
  }

  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        Fluttertoast.showToast(msg: "Google Sign-In cancelled");
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        Fluttertoast.showToast(msg: "Google Sign-In successful");
        await Hive.box('user').put('userId', user.uid); // Save user ID in Hive
        await Hive.box('user').put('displayName', user.displayName); // Save display name
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Google Sign-In failed: $e");
    }
  }

  void _handleSocialLogin(String platform) {
    if (platform == 'Google') {
      _loginWithGoogle();
    } else {
      Fluttertoast.showToast(msg: "Logging in with $platform");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              width: MediaQuery.of(context).size.width * 0.85,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.3),
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.3),
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock, color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    obscureText: true,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            activeColor: Colors.white,
                          ),
                          Text(
                            'Remember me',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/reset_password'),
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 80),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.4),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Or continue with',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _socialButton(
                        icon: Icons.g_mobiledata,
                        color: Colors.red,
                        onPressed: () => _handleSocialLogin('Google'),
                      ),
                      SizedBox(width: 20),
                      _socialButton(
                        icon: Icons.facebook,
                        color: Colors.blue,
                        onPressed: () => _handleSocialLogin('Facebook'),
                      ),
                      SizedBox(width: 20),
                      _socialButton(
                        icon: Icons.camera_alt,
                        color: Colors.pink,
                        onPressed: () => _handleSocialLogin('Instagram'),
                      ),
                      SizedBox(width: 20),
                      _socialButton(
                        icon: Icons.code,
                        color: Colors.white,
                        onPressed: () => _handleSocialLogin('GitHub'),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/signup'),
                    child: Text(
                      "Don't have an account? Register",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        iconSize: 30,
        padding: EdgeInsets.all(8),
      ),
    );
  }
}
