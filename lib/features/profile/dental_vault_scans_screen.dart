import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/badge_chip.dart';

/// Screen 21: saved_3d_intraoral_scans_dental_vault
/// High-security 3D Intraoral Scans & Digital Dental Cast Vault
class DentalVaultScansScreen extends StatelessWidget {
  const DentalVaultScansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '3D INTRAORAL VAULT',
          style: AppTypography.labelLG(color: AppColors.textPrimary).copyWith(letterSpacing: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Interactive 3D STL Mesh Preview Box
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.darkBase,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.darkBorder),
                boxShadow: const [AppColors.goldGlow],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.25,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=600&auto=format&fit=crop',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            AppBadgeChip(
                              label: 'ACTIVE 3D CAD MODEL',
                              variant: BadgeChipVariant.goldPurity,
                            ),
                            AppBadgeChip(
                              label: '99.8% PRECISION',
                              variant: BadgeChipVariant.statusSage,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upper Maxillary STL Mesh',
                              style: AppTypography.headlineMD(color: AppColors.textOnDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Verified by Dr. Adebayo DDS • Ready for 18K casting',
                              style: AppTypography.bodyXS(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Scan List Header
            Text(
              'Stored Arch Impressions & Scans',
              style: AppTypography.headlineMD(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            // Scans List
            Column(
              children: MockDataService.scans.map((scan) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineLight),
                    boxShadow: const [AppColors.softCardShadow],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: const Icon(Icons.view_in_ar, color: AppColors.primaryGold, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  scan.title,
                                  style: AppTypography.headlineSM().copyWith(fontSize: 14),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, size: 14, color: AppColors.emeraldGreen),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${scan.scanDate} • ${scan.verifiedBy}',
                              style: AppTypography.bodyXS(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${scan.fileFormat} (${scan.fileSize}) • ${scan.precisionScore}% accuracy',
                              style: AppTypography.bodyXS(color: AppColors.textMuted).copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 20),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Actions: Upload & Clinic Appointment
            AppButton.primary(
              text: 'UPLOAD NEW STL / PLY SCAN',
              prefixIcon: const Icon(Icons.upload_file, size: 18, color: AppColors.textOnGold),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selecting 3D STL intraoral mesh file...')),
                );
              },
            ),
            const SizedBox(height: 12),
            AppButton.outline(
              text: 'BOOK 3D INTRAORAL SCAN APPOINTMENT',
              prefixIcon: const Icon(Icons.calendar_today, size: 16, color: AppColors.primaryGold),
              onPressed: () => context.push('/concierge-booking'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
