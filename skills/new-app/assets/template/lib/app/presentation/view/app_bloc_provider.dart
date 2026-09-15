import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kit_template_app/app/presentation/bloc/app_bloc.dart';
import 'package:kit_template_app/core/injections/injection.dart';

abstract class AppBlocProvider {
  static List<BlocProvider<dynamic>> providers = [
    BlocProvider<AppBloc>.value(value: sl<AppBloc>()),
  ];
}
