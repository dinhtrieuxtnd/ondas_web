import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_semantic_colors.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/core/theme/app_typography.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/core/utils/validators.dart';
import 'package:ondas_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ondas_web/features/auth/presentation/bloc/auth_event.dart';
import 'package:ondas_web/features/auth/presentation/bloc/auth_state.dart';

class LoginFormWidget extends StatefulWidget {
  const LoginFormWidget({super.key});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginSubmitted(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final errorMessage =
          state is AuthFailure ? context.translateErrorCode(state.message) : null;
        final semanticColors =
            Theme.of(context).extension<AppSemanticColors>();

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (errorMessage != null) ...[
                _ErrorBanner(
                  message: errorMessage,
                  semanticColors: semanticColors,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              _PillTextField(
                key: const Key('loginForm_emailField'),
                controller: _emailController,
                label: context.translate('ui.auth.email_label'),
                keyboardType: TextInputType.emailAddress,
                enabled: !isLoading,
                validator: Validators.email,
              ),
              const SizedBox(height: AppSpacing.md),
              _PillTextField(
                key: const Key('loginForm_passwordField'),
                controller: _passwordController,
                label: context.translate('ui.auth.password_label'),
                obscureText: _obscurePassword,
                enabled: !isLoading,
                validator: Validators.password,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                    color: AppColors.stone,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _SubmitButton(
                key: const Key('loginForm_submitButton'),
                isLoading: isLoading,
                onPressed: _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final AppSemanticColors? semanticColors;

  const _ErrorBanner({required this.message, required this.semanticColors});

  @override
  Widget build(BuildContext context) {
    final bg = semanticColors?.errorSurface ?? AppColors.errorSurfaceLight;
    final fg = semanticColors?.error ?? AppColors.errorLight;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.smMd,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.container),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: fg),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(color: fg),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  const _PillTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightGray;
    final fillColor = isDark ? AppColors.darkSurface : AppColors.pureWhite;
    final hintColor = AppColors.silver;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTypography.body.copyWith(
        color: isDark ? AppColors.darkTextPrimary : AppColors.nearBlack,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.caption.copyWith(color: hintColor),
        filled: true,
        fillColor: fillColor,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorderStrong : AppColors.midGray,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: AppColors.errorLight),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: AppColors.errorLight),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.5)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.smMd + AppSpacing.xxs,
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pureBlack,
          foregroundColor: AppColors.pureWhite,
          disabledBackgroundColor: AppColors.midGray,
          disabledForegroundColor: AppColors.silver,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.buttonHorizontal,
            vertical: AppSpacing.buttonVertical,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.pureWhite,
                ),
              )
            : Text(
                context.translate('ui.auth.login_button'),
                style: AppTypography.body.copyWith(
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
