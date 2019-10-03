import 'package:businesslibrary/data/dashboard_data.dart';
import 'package:flutter/material.dart';

class DashProvider extends InheritedWidget {
  final DashboardData dashboardData;
  final Widget child;

  DashProvider(
    this.dashboardData,
    this.child,
  );

  static DashProvider of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(DashProvider);

  @override
  bool updateShouldNotify(DashProvider oldWidget) {
    return dashboardData != oldWidget.dashboardData;
  }
}
