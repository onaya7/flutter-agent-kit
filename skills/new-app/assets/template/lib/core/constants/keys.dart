import 'package:flutter/material.dart';

abstract class Keys {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<ScaffoldState> shellScaffoldKey =
      GlobalKey<ScaffoldState>();
}
