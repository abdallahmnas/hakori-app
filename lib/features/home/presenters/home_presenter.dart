import 'package:flutter/foundation.dart';
import '../models/home_model.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';

/// Presenter for the Home feature.
/// Contains business logic and exposes UI state via [ChangeNotifier].
class HomePresenter extends ChangeNotifier {
  HomeModel _homeModel = HomeModel(
    appName: AppConstants.appName,
    welcomeMessage: 'Discover, connect, and explore with ${AppConstants.appName}. '
        'Your journey to something extraordinary begins here.',
    quickActions: [
      QuickAction(
        title: 'My Profile',
        subtitle: 'View and manage your profile',
        routeName: AppRouter.profileName,
        iconAsset: AppConstants.profilePlaceholderSvg,
      ),
    ],
  );

  HomeModel get homeModel => _homeModel;
  String get appName => _homeModel.appName;
  String get welcomeMessage => _homeModel.welcomeMessage;
  List<QuickAction> get quickActions => _homeModel.quickActions;

  /// Update the welcome message (example of presenter logic).
  void updateWelcomeMessage(String message) {
    _homeModel = HomeModel(
      appName: _homeModel.appName,
      welcomeMessage: message,
      quickActions: _homeModel.quickActions,
    );
    notifyListeners();
  }
}
