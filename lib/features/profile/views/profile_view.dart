import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/image_picker_service.dart';
import '../presenters/profile_presenter.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/image_source_bottom_sheet.dart';

/// Profile screen view — renders UI from [ProfilePresenter] state.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Scope the ProfilePresenter to this route
    return ChangeNotifierProvider(
      create: (context) => ProfilePresenter(
        context.read<ImagePickerService>(),
      ),
      child: const _ProfileViewBody(),
    );
  }
}

class _ProfileViewBody extends StatelessWidget {
  const _ProfileViewBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Consumer<ProfilePresenter>(
        builder: (context, presenter, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.spacingLg,
            ),
            child: Column(
              children: [
                // Error banner
                if (presenter.errorMessage != null) ...[
                  _ErrorBanner(
                    message: presenter.errorMessage!,
                    onDismiss: presenter.clearError,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                ],

                // Profile avatar
                ProfileAvatar(
                  imagePath: presenter.profileImagePath,
                  isLoading: presenter.isLoading,
                  onTap: () => _showImagePicker(context, presenter),
                ),
                const SizedBox(height: AppConstants.spacingLg),

                // User name
                Text(
                  presenter.userName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppConstants.spacingXs),

                // Bio
                if (presenter.bio != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingXl,
                    ),
                    child: Text(
                      presenter.bio!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),

                const SizedBox(height: AppConstants.spacingXl),

                // Profile actions
                _ProfileSection(
                  title: 'Profile Settings',
                  children: [
                    _ActionTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Name',
                      subtitle: presenter.userName,
                      onTap: () => _showEditNameDialog(context, presenter),
                    ),
                    _ActionTile(
                      icon: Icons.camera_alt_outlined,
                      title: 'Change Photo',
                      subtitle: presenter.hasProfileImage
                          ? 'Tap to change'
                          : 'No photo set',
                      onTap: () => _showImagePicker(context, presenter),
                    ),
                    if (presenter.hasProfileImage)
                      _ActionTile(
                        icon: Icons.delete_outline_rounded,
                        title: 'Remove Photo',
                        subtitle: 'Reset to default',
                        isDestructive: true,
                        onTap: presenter.removeProfileImage,
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showImagePicker(
    BuildContext context,
    ProfilePresenter presenter,
  ) async {
    final source = await ImageSourceBottomSheet.show(context);
    if (source != null) {
      await presenter.pickProfileImage(source);
    }
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    ProfilePresenter presenter,
  ) async {
    final controller = TextEditingController(text: presenter.userName);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
          ),
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (result != null && result.trim().isNotEmpty) {
      presenter.updateUserName(result);
    }
  }
}

/// Error banner shown at the top of the profile screen.
class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
      ),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDismiss,
            color: AppColors.error,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

/// Section container with a header title.
class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Divider(
                    height: 1,
                    indent: AppConstants.spacingMd + 44 + AppConstants.spacingMd,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual action tile within a profile section.
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        isDestructive ? AppColors.error : AppColors.primary;
    final bgColor = isDestructive
        ? AppColors.errorContainer
        : AppColors.primaryContainer;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDestructive
                                    ? AppColors.error
                                    : null,
                              ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
