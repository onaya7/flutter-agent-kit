import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kit_template_app/app/presentation/bloc/app_bloc.dart';
import 'package:kit_template_app/core/injections/injection.dart';

/// Every bloc and cubit is mounted here. Add a `resetAll()` beside `providers` once one of
/// them holds per-visit state, and call it on sign-out.
abstract class AppBlocProvider {
  static List<BlocProvider<dynamic>> providers = [
    BlocProvider<AppBloc>.value(value: sl<AppBloc>()),
  ];
}
