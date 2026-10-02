/// Data model for the home screen.
class HomeModel {
  final String appName;
  final String welcomeMessage;
  final List<QuickAction> quickActions;

  const HomeModel({
    required this.appName,
    required this.welcomeMessage,
    required this.quickActions,
  });
}

/// Represents a navigable quick action on the home screen.
class QuickAction {
  final String title;
  final String subtitle;
  final String routeName;
  final String? iconAsset;

  const QuickAction({
    required this.title,
    required this.subtitle,
    required this.routeName,
    this.iconAsset,
  });
}
