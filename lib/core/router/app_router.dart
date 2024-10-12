import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/features/home/homepage.dart';
import 'package:go_router/go_router.dart';

/// AppRouter class is used to define the routes of the application.
/// App uses GoRouter package to manage the routes. Please refer to the GoRouter documentation for more information.
/// https://pub.dev/packages/go_router
class AppRouter {
  static final router = GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomePage(),
      ),
    ],
  );
}
