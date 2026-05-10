import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_bloc.dart';
import 'package:mynotes/services/auth/bloc/auth_event.dart';
import 'package:mynotes/services/auth/bloc/auth_state.dart';

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthStateLoggedIn) {
          // Navigate to notes view when email is verified
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/notes/', (route) => false);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Verify Email')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Please verify your email address',
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'We have sent you an email verification link. Please check your inbox and click the link to verify your email address.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                        const AuthEventSendEmailVerification(),
                      );
                    },
                    child: const Text('Send Email Verification'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(const AuthEventLogOut());
                    },
                    child: const Text('Log Out'),
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
