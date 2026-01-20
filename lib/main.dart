import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/views/register_view.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'views/login_view.dart'; // <--- add this import
import 'dart:developer' as devtools show log;

void log() {}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on UnsupportedError catch (e) {
    debugPrint('Firebase not configured for this platform: $e');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
      routes: {
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/notes': (context) => const NotesView(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginView();
        } else if (!user.emailVerified) {
          return const VerifyEmailView();
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              actions: [
                PopupMenuButton<MenuAction>(
                  onSelected: (value) async {
                    switch (value) {
                      case MenuAction.logout:
                        final confirmed = await showLogoutDialog(context);
                        if (confirmed) {
                          await FirebaseAuth.instance.signOut();
                        }
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem<MenuAction>(
                        value: MenuAction.logout,
                        child: Text('Logout'),
                      ),
                    ];
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('User is logged in and email is verified'),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  Timer? _verificationTimer;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    super.dispose();
  }

  void _startEmailVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) {
        _verificationTimer?.cancel();
        return;
      }

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await user.reload();
        }
      } catch (e) {
        debugPrint('Error reloading user: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Please verify your email address.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No user found. Please log in again.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                    return;
                  }

                  await user.sendEmailVerification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Verification email sent. Check your inbox and spam folder.',
                        ),
                        duration: Duration(seconds: 4),
                      ),
                    );
                  }
                } on FirebaseAuthException catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error sending email: ${e.message}'),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                  debugPrint('Email verification error: ${e.message}');
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                  debugPrint('Unexpected error: $e');
                }
              },
              child: const Text('Resend Verification Email'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}

enum MenuAction { logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              devtools.log(value.toString());
              switch (value) {
                case MenuAction.logout:
                  final confirmed = await showLogoutDialog(context);
                  if (confirmed) {
                    await FirebaseAuth.instance.signOut();
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
              ];
            },
          ),
        ],
      ),
      body: const Center(child: Text('This is the Notes View')),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // User canceled
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // User confirmed
            },
            child: const Text('Sign Out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
