import 'package:flutter/material.dart';
import '../../../constants.dart';

class FulfillmentSelector extends StatelessWidget {
  final bool isDelivery;
  final ValueChanged<bool> onChanged;

  const FulfillmentSelector({
    super.key,
    required this.isDelivery,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(kPaddingM),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(kRadiusL + 4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(kPaddingS),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(kRadiusM),
                ),
                child: Icon(Icons.delivery_dining, color: colorScheme.primary),
              ),
              const SizedBox(width: kPaddingM - 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      kFulfillmentMethod,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      kChooseFulfillment,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: kPaddingM),
          Row(
            children: [
              Expanded(
                child: _buildToggleButton(
                  Icons.motorcycle,
                  kDelivery,
                  isDelivery,
                  colorScheme,
                ),
              ),
              const SizedBox(width: kPaddingM - 4),
              Expanded(
                child: _buildToggleButton(
                  Icons.store,
                  kStorePickup,
                  !isDelivery,
                  colorScheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    IconData icon,
    String label,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: () => onChanged(label == kDelivery),
      borderRadius: BorderRadius.circular(kRadiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: kPaddingM - 4),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(kRadiusM),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: kPaddingS),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
