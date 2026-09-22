import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../app/theme/app_colors.dart';
import 'cubit/auth_cubit.dart';
import 'cubit/auth_state.dart';
import 'login_cover_strips.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegister = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final cubit = context.read<AuthCubit>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isRegister) {
      await cubit.signUpWithEmail(
        name: _nameController.text.trim(),
        email: email,
        password: password,
      );
      return;
    }

    await cubit.signInWithEmail(email: email, password: password);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: AppColors.background)),
          const Positioned.fill(child: LoginCoverStrips()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      final loading = state is AuthLoading;
                      final error = state is AuthError ? state.message : null;

                      return AutofillGroup(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),
                              Text(
                                'GAMEVAULT',
                                textAlign: TextAlign.center,
                                style: textTheme.displaySmall,
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: ColoredBox(
                                  color: AppColors.accent,
                                  child: SizedBox(width: 48, height: 2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isRegister
                                    ? 'Crea tu bóveda personal'
                                    : 'Tu bóveda de juegos',
                                textAlign: TextAlign.center,
                                style: textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 40),
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.glass,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppColors.outline),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      if (_isRegister) ...[
                                        TextFormField(
                                          controller: _nameController,
                                          enabled: !loading,
                                          textCapitalization:
                                              TextCapitalization.words,
                                          textInputAction: TextInputAction.next,
                                          decoration: const InputDecoration(
                                            labelText: 'Nombre',
                                          ),
                                          validator: (value) {
                                            if (!_isRegister) {
                                              return null;
                                            }
                                            if (value == null ||
                                                value.trim().isEmpty) {
                                              return 'Escribe tu nombre';
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      TextFormField(
                                        controller: _emailController,
                                        enabled: !loading,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        autofillHints: const [
                                          AutofillHints.email,
                                        ],
                                        textInputAction: TextInputAction.next,
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                        ),
                                        validator: (value) {
                                          final email = value?.trim() ?? '';
                                          if (email.isEmpty ||
                                              !email.contains('@')) {
                                            return 'Escribe un email válido';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _passwordController,
                                        enabled: !loading,
                                        obscureText: _obscurePassword,
                                        autofillHints: [
                                          _isRegister
                                              ? AutofillHints.newPassword
                                              : AutofillHints.password,
                                        ],
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _submit(),
                                        decoration: InputDecoration(
                                          labelText: 'Contraseña',
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                            ),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null ||
                                              value.length < 6) {
                                            return 'Mínimo 6 caracteres';
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (error != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  error,
                                  textAlign: TextAlign.center,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              FilledButton(
                                onPressed: loading ? null : _submit,
                                child: loading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _isRegister
                                            ? 'Crear cuenta'
                                            : 'Entrar',
                                      ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'o',
                                      style: textTheme.bodyMedium,
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: loading
                                    ? null
                                    : () => context
                                          .read<AuthCubit>()
                                          .signInWithGoogle(),
                                icon: const Icon(Icons.g_mobiledata_rounded),
                                label: const Text('Continuar con Google'),
                              ),
                              const SizedBox(height: 24),
                              TextButton(
                                onPressed: loading
                                    ? null
                                    : () {
                                        setState(() {
                                          _isRegister = !_isRegister;
                                        });
                                      },
                                child: Text(
                                  _isRegister
                                      ? '¿Ya tienes cuenta? Entra'
                                      : '¿No tienes cuenta? Regístrate',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
