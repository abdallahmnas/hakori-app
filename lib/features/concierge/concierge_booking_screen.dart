import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/badge_chip.dart';

/// Screen 22: vip_concierge_1_on_1_consultation_booking
/// VIP Concierge & Master Jeweler Private Consultation Booking Form
class ConciergeBookingScreen extends StatefulWidget {
  const ConciergeBookingScreen({super.key});

  @override
  State<ConciergeBookingScreen> createState() => _ConciergeBookingScreenState();
}

class _ConciergeBookingScreenState extends State<ConciergeBookingScreen> {
  String _selectedJeweler = 'Jean-Luc Atelier (Place Vendôme)';
  String _selectedLocation = 'Virtual HD Video Studio';
  String _selectedDate = 'Tomorrow, Sept 22';
  String _selectedTime = '03:00 PM CET';
  final TextEditingController _notesController = TextEditingController();

  final List<String> _jewelers = [
    'Jean-Luc Atelier (Place Vendôme)',
    'Dr. Adebayo DDS (Lagos Clinical Director)',
    'Henri Rousseau (Senior Gemologist)',
  ];

  final List<String> _locations = [
    'Virtual HD Video Studio',
    'Place Vendôme Salon (Paris)',
    'Victoria Island Penthouse (Lagos)',
    'Dubai International Salon (DIFC)',
  ];

  final List<String> _times = [
    '11:00 AM CET',
    '01:30 PM CET',
    '03:00 PM CET',
    '05:00 PM CET',
    '07:30 PM CET',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

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
          'VIP CONCIERGE BOOKING',
          style: AppTypography.labelLG(color: AppColors.textPrimary).copyWith(letterSpacing: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.darkBase,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkBorder),
                boxShadow: const [AppColors.goldGlow],
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: AppColors.primaryGold, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppBadgeChip(
                          label: 'COMPLIMENTARY VIP SERVICE',
                          variant: BadgeChipVariant.goldPurity,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '1-on-1 Master Jeweler Session',
                          style: AppTypography.headlineMD(color: AppColors.textOnDark),
                        ),
                        Text(
                          'Review 3D intraoral CAD designs, precious metals, and gemstone clarity with our senior artisan.',
                          style: AppTypography.bodyXS(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Select Master Jeweler
            _buildSectionTitle('1. Select Master Jeweler or Gemologist'),
            Column(
              children: _jewelers.map((jeweler) {
                final isSelected = jeweler == _selectedJeweler;
                return InkWell(
                  onTap: () => setState(() => _selectedJeweler = jeweler),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceContainerLow : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryGold : AppColors.outlineLight,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? AppColors.primaryGold : AppColors.textMuted,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            jeweler,
                            style: AppTypography.labelMD(color: AppColors.textPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Select Consultation Format
            _buildSectionTitle('2. Select Salon Location or Video Format'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _locations.map((loc) {
                final isSelected = loc == _selectedLocation;
                return AppBadgeChip(
                  label: loc,
                  variant: BadgeChipVariant.outline,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedLocation = loc),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Select Date
            _buildSectionTitle('3. Preferred Consultation Date'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Today, Sept 21', 'Tomorrow, Sept 22', 'Wednesday, Sept 23', 'Thursday, Sept 24'].map((date) {
                final isSelected = date == _selectedDate;
                return AppBadgeChip(
                  label: date,
                  variant: BadgeChipVariant.outline,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedDate = date),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Select Time Slot
            _buildSectionTitle('4. Preferred Time Slot'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _times.map((time) {
                final isSelected = time == _selectedTime;
                return AppBadgeChip(
                  label: time,
                  variant: BadgeChipVariant.outline,
                  isSelected: isSelected,
                  onTap: () => setState(() => _selectedTime = time),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Notes / Vision
            _buildSectionTitle('4. Commission Vision / Notes (Optional)'),
            AppTextField(
              hintText: 'e.g. Seeking top 8 honeycomb emerald piece for upcoming gala...',
              controller: _notesController,
              maxLines: 3,
            ),
            const SizedBox(height: 28),

            // Confirmation CTA
            AppButton.primary(
              text: 'CONFIRM VIP CONSULTATION',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Consultation booked with $_selectedJeweler for $_selectedTime'),
                    backgroundColor: AppColors.darkBase,
                  ),
                );
                context.push('/live-call');
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: AppTypography.headlineSM(color: AppColors.textPrimary),
      ),
    );
  }
}
