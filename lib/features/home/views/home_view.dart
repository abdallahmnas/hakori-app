import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../presenters/home_presenter.dart';
import '../widgets/welcome_card.dart';
import '../widgets/quick_action_button.dart';

/// Home screen view — renders UI from [HomePresenter] state.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomePresenter(),
      child: const _HomeViewBody(),
    );
  }
}

class _HomeViewBody extends StatelessWidget {
  const _HomeViewBody();

  @override
  Widget build(BuildContext context) {
    final presenter = context.watch<HomePresenter>();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              floating: true,
              title: Text(
                presenter.appName,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications coming soon!'),
                      ),
                    );
                  },
                ),
                const SizedBox(width: AppConstants.spacingXs),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppConstants.spacingSm),

                  // Welcome card
                  WelcomeCard(
                    appName: presenter.appName,
                    welcomeMessage: presenter.welcomeMessage,
                  ),

                  const SizedBox(height: AppConstants.spacingLg),

                  // Section header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMd,
                    ),
                    child: Text(
                      'Quick Actions',
                      style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),

                  // Quick action buttons
                  ...presenter.quickActions.map(
                    (action) => QuickActionButton(
                      title: action.title,
                      subtitle: action.subtitle,
                      iconAsset: action.iconAsset,
                      onTap: () => context.pushNamed(action.routeName),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
