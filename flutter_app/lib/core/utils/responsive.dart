import 'package:flutter/material.dart';

class Responsive {
  const Responsive._();

  static bool isCompact(BuildContext context) =>
      MediaQuery.of(context).size.width < 380;

  static bool isSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < 430;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 700;

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 380) return 14;
    if (width < 430) return 18;
    if (width < 700) return 22;
    return 28;
  }

  static double pageMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 700) return 430;
    if (width < 1000) return 560;
    return 680;
  }

  static double titleSize(BuildContext context, {double compact = 18, double normal = 20}) {
    return isCompact(context) ? compact : normal;
  }

  static double sectionTitleSize(BuildContext context,
      {double compact = 16, double normal = 18}) {
    return isCompact(context) ? compact : normal;
  }

  static double bodySize(BuildContext context,
      {double compact = 13.5, double normal = 15}) {
    return isCompact(context) ? compact : normal;
  }

  static double controlHeight(BuildContext context,
      {double compact = 48, double normal = 52}) {
    return isCompact(context) ? compact : normal;
  }

  static EdgeInsets pagePadding(BuildContext context,
      {double top = 14, double bottom = 18}) {
    final horizontal = horizontalPadding(context);
    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }
}
