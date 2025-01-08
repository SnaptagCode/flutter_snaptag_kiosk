import 'package:flutter/widgets.dart';

import 'logger_service.dart';

List<Route<dynamic>> routeStack = [];

class NavObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeStack.add(route);
    logger.d('didPush');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeStack.removeLast();
    logger.d('didPop');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    routeStack.removeLast();
    logger.d('didRemove');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    logger.d('didReplace');
    routeStack.removeLast();
    routeStack.add(newRoute!);
  }

  @override
  void didStartUserGesture(
    Route<dynamic> route,
    Route<dynamic>? previousRoute,
  ) {
    // logger.d('didStartUserGesture');
  }

  @override
  void didStopUserGesture() {
    // logger.d('didStopUserGesture');
  }
}
