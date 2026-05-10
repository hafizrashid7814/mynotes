import 'package:flutter/material.dart';

import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateLoggedOut &&
            state.exception != null &&
            state.exception is UserNotFoundAuthException) {
          await showErrorDialog(
            context,
            'Cannot find a user with the entered credentials!',
          );
        } else if (state is AuthStateLoggedOut &&
            state.exception != null &&
            state.exception is WrongPasswordAuthException) {
          await showErrorDialog(context, 'wrong credentials');
        } else if (state is AuthStateLoggedOut &&
            state.exception != null &&
            state.exception is GenericAuthException) {
          await showErrorDialog(context, 'Authentication error');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Please log into your account in order to interact with and create notes!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      context.read<AuthBloc>().add(
                        AuthEventLogIn(
                          email: _email.text,
                          password: _password.text,
                        ),
                      );
                    },
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        const AuthEventShouldRegister(),
                      );
                    },
                    child: const Text('Don\'t have an account? Register'),
                  ),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        const AuthEventForgotPassword(email: 'email'),
                      );
                    },
                    child: const Text('I forgot my password'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
