import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ondas_web/core/constants/app_constants.dart';
import 'package:ondas_web/core/theme/app_colors.dart';
import 'package:ondas_web/core/theme/app_radius.dart';
import 'package:ondas_web/core/theme/app_spacing.dart';
import 'package:ondas_web/core/theme/app_typography.dart';
import 'package:ondas_web/core/localization/localization_extensions.dart';
import 'package:ondas_web/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ondas_web/features/auth/presentation/bloc/auth_state.dart';
import 'package:ondas_web/features/auth/presentation/widgets/login_form_widget.dart';
import 'package:ondas_web/features/auth/presentation/widgets/ondas_logo_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go(AppConstants.routeDashboard);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: _LoginCard(),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkSurface : AppColors.pureWhite;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightGray;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.container),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LoginHeader(),
          const SizedBox(height: AppSpacing.xxxl),
          const LoginFormWidget(),
        ],
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.pureBlack;
    final subtitleColor = AppColors.stone;
    final dividerColor = isDark ? AppColors.darkBorder : AppColors.lightGray;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const OndasLogoWidget(),
        const SizedBox(height: AppSpacing.xxl),
        Divider(color: dividerColor, thickness: 1),
        const SizedBox(height: AppSpacing.xxl),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.translate('ui.auth.login_title'),
                style: AppTypography.headingMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                context.translate('ui.auth.welcome_back'),
                style: AppTypography.body.copyWith(color: subtitleColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
