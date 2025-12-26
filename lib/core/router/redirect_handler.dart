import 'package:airspothealth/core/router/app_router.dart';
import 'package:airspothealth/core/router/route_names.dart';
import 'package:airspothealth/core/services/map_handoff_service.dart';
import 'package:airspothealth/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RedirectHandler {
  /// Handles all redirect logic for the app router
  static String? handleRedirect(BuildContext context, GoRouterState state) {
    debugPrint(
        'Redirecting to: ${state.uri}, Paths: ${state.uri.pathSegments}');
    final uri = Uri.parse(state.uri.toString());

    // Handle custom scheme deep links like airspothealth://devices...
    final customSchemeRedirect = _handleCustomSchemeRedirect(uri);
    if (customSchemeRedirect != null) {
      return customSchemeRedirect;
    }

    // Redirect malformed paths missing "/devices"
    final malformedPathRedirect = _handleMalformedPathRedirect(uri);
    if (malformedPathRedirect != null) {
      return malformedPathRedirect;
    }

    // Handle legacy open_map deep link
    final openMapResult = _handleOpenMapRedirect(uri);
    if (openMapResult != null) {
      return openMapResult;
    }

    // Handle restart live activity deep link
    final restartLiveActivityRedirect = _handleRestartLiveActivityRedirect(uri);
    if (restartLiveActivityRedirect != null) {
      return restartLiveActivityRedirect;
    }

    // Handle map handoff deep link
    final mapHandoffResult = _handleMapHandoffRedirect(uri);
    if (mapHandoffResult != null) {
      return mapHandoffResult;
    }

    return null; // No redirect
  }

  /// Handles custom scheme deep links like airspothealth://devices...
  static String? _handleCustomSchemeRedirect(Uri uri) {
    // In a custom scheme, the host is the first segment (e.g., "devices")
    // and the path contains the rest. Normalize these into Flutter paths.
    if (uri.scheme.isNotEmpty && uri.host == 'devices') {
      final segments = uri.pathSegments;

      // airspothealth://devices or airspothealth://devices/
      if (segments.isEmpty) {
        // Check if this is from a widget click
        final fromWidget = uri.queryParameters['from'] == 'widget';
        if (fromWidget) {
          // For widget clicks, start at home and navigate programmatically
          // This preserves the navigation stack so users can go back
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final context = AppRouter.navigatorKey.currentContext;
            if (context != null) {
              context.pushNamed(RouteNames.devices);
            }
          });
          return RouteNames.home; // Start at home page
        }
        return '/devices';
      }

      // airspothealth://devices/<deviceId>
      if (segments.length == 1) {
        final deviceId = segments.first;
        if (deviceId.isEmpty) return '/devices';

        // Check if this is from an expired live activity
        final fromExpired = uri.queryParameters['from'] == 'expired';
        if (fromExpired) {
          // For expired live activity clicks, start at home and navigate programmatically
          // This preserves the navigation stack so users can go back
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final context = AppRouter.navigatorKey.currentContext;
            if (context != null) {
              final query = uri.hasQuery ? '?${uri.query}' : '';
              context.push('/devices/$deviceId$query');
            }
          });
          return RouteNames.home; // Start at home page
        }

        return '/devices/$deviceId';
      }

      // airspothealth://devices/<deviceId>/graph
      if (segments.length >= 2 && segments[1] == 'graph') {
        final deviceId = segments[0];
        // Check if this is from a notification click
        final fromNotification = uri.queryParameters['from'] == 'notification';
        if (fromNotification) {
          // For notification clicks, start at home and navigate programmatically
          // This preserves the navigation stack so users can go back
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final context = AppRouter.navigatorKey.currentContext;
            if (context != null) {
              context.pushNamed(RouteNames.deviceGraph,
                  pathParameters: {'deviceId': deviceId});
            }
          });
          return RouteNames.home; // Start at home page
        }
        return '/devices/$deviceId/graph';
      }

      // airspothealth://devices/<deviceId>/settings[?query]
      if (segments.length >= 2 && segments[1] == 'settings') {
        final deviceId = segments[0];
        final query = uri.hasQuery ? '?${uri.query}' : '';
        return '/devices/$deviceId/settings$query';
      }

      // Fallback to devices list for any other /devices deep links
      return '/devices';
    }

    return null;
  }

  /// Redirects malformed paths missing "/devices"
  static String? _handleMalformedPathRedirect(Uri uri) {
    // Define known app routes that should not be treated as device IDs
    const knownAppRoutes = {
      'app-setup',
      'solutions',
      'latest-news',
      'app-updates',
      'privacy-policy',
      'factory-test',
      'map-handoff',
      'find-my-device',
      'report-issue',
    };

    // Handle malformed device ID paths (missing /devices prefix)
    if (uri.pathSegments.length == 1 &&
        !uri.pathSegments.contains('devices') &&
        uri.pathSegments[0].contains('-') &&
        !knownAppRoutes.contains(uri.pathSegments[0])) {
      // Device IDs typically contain hyphens
      final deviceId = uri.pathSegments[0];
      // Check if this is from an expired live activity
      final fromExpired = uri.queryParameters['from'] == 'expired';
      if (fromExpired) {
        final query = uri.hasQuery ? '?${uri.query}' : '';
        return '/devices/$deviceId$query';
      }
      return '/devices/$deviceId';
    }

    // Handle graph paths
    if (uri.pathSegments.length == 2 &&
        uri.pathSegments[1] == 'graph' &&
        !uri.pathSegments.contains('devices')) {
      final deviceId = uri.pathSegments[0];
      return '/devices/$deviceId/graph';
    }

    return null;
  }

  /// Handles legacy airspothealth://open_map deep link
  static String? _handleOpenMapRedirect(Uri uri) {
    if (uri.host.contains('open_map')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('Opening map URL');
        // Open the map URL in an external browser
        launchUrlString(Constants.mapUrl, mode: LaunchMode.externalApplication)
            .then((success) {
          if (!success) {
            debugPrint('Failed to open map URL: ${Constants.mapUrl}');
          }
        }).catchError((error) {
          debugPrint('Error opening map URL: $error');
        });
      });
      // Return null to indicate no redirect is needed
      return null; // No redirect needed, we just open the URL
    }

    return null;
  }

  /// Handles restart live activity deep link
  static String? _handleRestartLiveActivityRedirect(Uri uri) {
    if (uri.host.contains('restart-live-activity')) {
      final deviceId = uri.queryParameters['deviceId'];
      debugPrint(
          '🔄 Restart Live Activity deep link detected for device: $deviceId');

      if (deviceId != null && deviceId.isNotEmpty) {
        // Route directly to the device route (which renders settings)
        return '/devices/$deviceId?from=restart';
      } else {
        // Fallback to devices page if no device ID
        return '/devices';
      }
    }

    return null;
  }

  /// Handles map handoff deep link
  static String? _handleMapHandoffRedirect(Uri uri) {
    if (uri.host.contains('map-handoff')) {
      final deviceId = uri.queryParameters['deviceId'];
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          // Build signed URL and open externally
          final service = MapHandoffService();
          final url = await service.buildSignedMapUrl(
            deviceId: deviceId ?? '',
            recordLimit: 500,
            useFragment: true,
          );
          await launchUrlString(url.toString(),
              mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('Failed to build/open map handoff URL: $e');
        }
      });
      return null;
    }

    return null;
  }
}
