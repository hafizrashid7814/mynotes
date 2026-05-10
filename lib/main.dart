import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/constants/routes.dart' show createOrUpdatNoteRoute;
import 'package:mynotes/helper/loading/loading_screen.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/services/auth/firebase_auth_provider.dart';
import 'package:mynotes/views/forgot_password_view.dart';
import 'package:mynotes/views/notes/create_update_note_view.dart'
    show CreateUpdateNoteView;
import 'package:mynotes/views/notes/notes_view.dart' show NotesView;
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/launch_screen_view.dart';

import 'dart:async';
import 'views/login_view.dart';

import 'package:mynotes/services/auth/auth_service.dart';

late AuthService _authService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    _authService = AuthService.firebase();
    await _authService.initialize();
  } catch (e) {
    debugPrint('Auth service initialization error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
      routes: {
        createOrUpdatNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? 'Please wait a moment',
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const NotesView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateForgotPassword) {
          return const ForgotPasswordView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return const LaunchScreenView();
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
        await _authService.initialize();
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
                final messenger = ScaffoldMessenger.of(context);

                try {
                  final user = _authService.currentUser;
                  if (user == null) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('No user found. Please log in again.'),
                        duration: Duration(seconds: 3),
                      ),
                    );
                    return;
                  }

                  await _authService.sendEmailVerification();
                  if (!mounted) return;

                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Verification email sent. Check your inbox and spam folder.',
                      ),
                      duration: Duration(seconds: 4),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text('Error sending email: $e'),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                  debugPrint('Email verification error: $e');
                }
              },
              child: const Text('Resend Verification Email'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await _authService.logOut();
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
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
