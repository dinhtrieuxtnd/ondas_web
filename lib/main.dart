import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:ondas_web/app/app.dart';
import 'package:ondas_web/app/bloc/locale_cubit.dart';
import 'package:ondas_web/core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  await sl<LocaleCubit>().load();
  runApp(
    BlocProvider.value(
      value: sl<LocaleCubit>(),
      child: const OndasApp(),
    ),
  );
}


