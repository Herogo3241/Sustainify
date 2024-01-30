import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_code/Utils/Navbar.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(labelText: 'Username'),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Password'),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _signUp,
                      child: Text('Sign Up'),
                    ),
                    SizedBox(height: 8.0),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Already have an account? Sign in'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _signUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await _saveUserInfoToFirestore();

      _navigateToHome();
    } catch (e) {
      print("Error during signup: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveUserInfoToFirestore() async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'username': _usernameController.text,
        'email': _emailController.text,
      });
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Navbar()),
    );
  }

  Future<void> _saveUsernameToFirestore() async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'username': _emailController.text, 'userId': user.uid});
    }
  }
}

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Password'),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: _signIn,
                      child: Text('Sign In'),
                    ),
                    SizedBox(height: 8.0),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text('Don\'t have an account? Sign up'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      _navigateToHome();
    } catch (e) {
      print("Error during signin: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Navbar()),
    );
  }
}

class AuthenticationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SignInScreen(); // Default to Sign In screen
  }
}
