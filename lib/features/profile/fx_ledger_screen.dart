import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/currency_provider.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/widgets/badge_chip.dart';

/// Screen 20: multi_currency_fx_ledger_settings
/// Multi-Currency FX Ledger with real-time gold spot rates and currency toggling
class FxLedgerScreen extends StatelessWidget {
  const FxLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'FX LEDGER SETTINGS',
          style: AppTypography.labelLG(color: AppColors.textPrimary).copyWith(letterSpacing: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Gold Spot Price Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkBase,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkBorder),
                boxShadow: const [AppColors.goldGlow],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      AppBadgeChip(
                        label: 'LIVE BULLION SPOT PRICE',
                        variant: BadgeChipVariant.goldPurity,
                      ),
                      Text('+0.84% (24H)', style: TextStyle(color: AppColors.emeraldGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '\$2,420.50 / Troy Oz',
                    style: AppTypography.headlineXL(color: AppColors.textOnDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'LBMA London Gold Fix benchmark • Real-time API sync',
                    style: AppTypography.bodyXS(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Select Base Display Currency
            Text(
              'Select Active Display & Settlement Currency',
              style: AppTypography.headlineMD(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineLight),
                boxShadow: const [AppColors.softCardShadow],
              ),
              child: Column(
                children: MockDataService.supportedCurrencies.map((curr) {
                  final isSelected = curr.code == currencyProvider.selectedCurrency.code;

                  return InkWell(
                    onTap: () {
                      currencyProvider.setCurrency(curr);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Active currency updated to ${curr.name} (${curr.code})'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Text(curr.flagEmoji, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${curr.code} • ${curr.name}',
                                  style: AppTypography.labelLG(color: AppColors.textPrimary),
                                ),
                                Text(
                                  curr.code == 'USD' ? 'Global Atelier Base (1.00)' : '1 USD = ${curr.symbol}${curr.rateToUsd}',
                                  style: AppTypography.bodyXS(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: AppColors.primaryGold, size: 22)
                          else
                            const Icon(Icons.radio_button_unchecked, color: AppColors.outline, size: 22),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Auto-Lock Volatility Protection
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_clock_outlined, color: AppColors.primaryGold, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Auto-Lock Rate on Bag Add (48H)',
                          style: AppTypography.labelMD(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Shields you from spot price surges during checkout.',
                          style: AppTypography.bodyXS(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: currencyProvider.autoLockRates,
                    activeColor: AppColors.primaryGold,
                    onChanged: (val) => currencyProvider.toggleAutoLock(val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
