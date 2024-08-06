import 'package:expanse_mate_demo_app/common/consts/app_routes.dart';
import 'package:expanse_mate_demo_app/profile/ui/dashboard.dart';
import 'package:expanse_mate_demo_app/profile/ui/expanse_profile_screen.dart';
import 'package:flutter/material.dart';

class AppRouteManager {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static PageRoute onGenerateRoute(RouteSettings settings) {
    final Map<String, dynamic>? args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case AppRoutes.expanseProfilePage:
        return MaterialPageRoute(
          builder: (context) => ExpanseProfilePage(index: args?['index'] ?? 0),
          settings: const RouteSettings(
            name: AppRoutes.expanseProfilePage,
          ),
        );
      case AppRoutes.dashboard:
        return MaterialPageRoute(
          builder: (context) => const Dashboard(),
          settings: const RouteSettings(
            name: AppRoutes.dashboard,
          ),
        );
    }

    return MaterialPageRoute(
      builder: (context) => const Center(
        child: Text('404!!'),
      ),
    );
  }

  static Future<T?>? pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    return navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  static Future<T?>? pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
    BuildContext? context,
  }) {
    if (context != null) {
      return Navigator.pushNamedAndRemoveUntil(context, newRouteName, predicate, arguments: arguments);
    }
    return (navigatorKey.currentState)
        ?.pushNamedAndRemoveUntil(newRouteName, predicate, arguments: arguments);
  }

  static void pop<T extends Object?>([T? result]) {
    return navigatorKey.currentState?.pop<T>(result);
  }

  static void popUntil<T extends Object?>(RoutePredicate predicate) {
    return navigatorKey.currentState?.popUntil(predicate);
  }

  static Future<T?> pushReplacementNamed<T extends Object?>(String route,
      {Map<String, dynamic>? arguments}) {
    return Navigator.of(navigatorKey.currentContext!).pushReplacementNamed(route, arguments: arguments);
  }
}
