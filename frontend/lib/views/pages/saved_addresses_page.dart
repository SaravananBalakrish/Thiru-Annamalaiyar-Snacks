import 'package:flutter/material.dart';

import 'map_picker_page.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controllers/address_controller.dart';
import '../../models/address.dart';

class SavedAddressesPage extends StatelessWidget {
  final bool isSelectionMode;
  const SavedAddressesPage({super.key, this.isSelectionMode = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectionMode ? "Select Address" : kSavedAddresses,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Consumer<AddressController>(
        builder: (context, controller, child) {
          if (controller.addresses.isEmpty) {
            return _buildEmptyState(theme, colorScheme, context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(kPaddingM),
            itemCount: controller.addresses.length,
            itemBuilder: (context, index) {
              final address = controller.addresses[index];
              return InkWell(
                onTap: isSelectionMode ? () => Navigator.pop(context, address) : null,
                child: _AddressCard(
                  address: address,
                  theme: theme,
                  colorScheme: colorScheme,
                  isSelectionMode: isSelectionMode,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAddressOptions(context),
        icon: const Icon(Icons.add),
        label: const Text("Add New Address"),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kPaddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(kPaddingL),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.location_off_outlined, size: 80, color: colorScheme.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: kPaddingL),
            Text(
              "No addresses saved",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: kPaddingS),
            Text(
              "Add your delivery address to enjoy faster checkout experience.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusL)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: kPaddingM),
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text("Select from Map"),
            subtitle: const Text("Pick location using GPS"),
            onTap: () {
              Navigator.pop(context);
              _navigateToMapPicker(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_note_outlined),
            title: const Text("Enter Manually"),
            subtitle: const Text("Type your address details"),
            onTap: () {
              Navigator.pop(context);
              _showAddAddressSheet(context);
            },
          ),
          const SizedBox(height: kPaddingL),
        ],
      ),
    );
  }

  Future<void> _navigateToMapPicker(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerPage()),
    );

    if (result != null && context.mounted) {
      _showAddAddressSheet(context, initialAddress: result['address']);
    }
  }

  void _showAddAddressSheet(BuildContext context, {String? initialAddress}) {
    final labelController = TextEditingController();
    final addressController = TextEditingController(text: initialAddress);
    final cityController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: kPaddingL,
          right: kPaddingL,
          top: kPaddingL,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Add New Address", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: kPaddingL),
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: "Label (e.g. Home, Office)"),
            ),
            const SizedBox(height: kPaddingM),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: "Full Address"),
              maxLines: 2,
            ),
            const SizedBox(height: kPaddingM),
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: "City"),
            ),
            const SizedBox(height: kPaddingL),
            ElevatedButton(
              onPressed: () {
                if (labelController.text.isNotEmpty &&
                    addressController.text.isNotEmpty &&
                    cityController.text.isNotEmpty) {
                  context.read<AddressController>().addAddress(
                    labelController.text,
                    addressController.text,
                    cityController.text,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Save Address"),
            ),
            const SizedBox(height: kPaddingL),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final bool isSelectionMode;

  const _AddressCard({
    required this.address,
    required this.theme,
    required this.colorScheme,
    this.isSelectionMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: kPaddingM),
      child: Padding(
        padding: const EdgeInsets.all(kPaddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  address.label.toLowerCase() == 'home' ? Icons.home_outlined : 
                  address.label.toLowerCase() == 'office' ? Icons.work_outline : Icons.location_on_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: kPaddingS),
                Text(address.label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text("DEFAULT", style: TextStyle(fontSize: 10, color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                  ),
                if (!isSelectionMode)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      if (!address.isDefault)
                        const PopupMenuItem(value: 'default', child: Text("Set as Default")),
                      const PopupMenuItem(value: 'delete', child: Text("Delete")),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        context.read<AddressController>().deleteAddress(address.id);
                      } else if (value == 'default') {
                        context.read<AddressController>().setDefault(address.id);
                      }
                    },
                  ),
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(left: kPaddingS),
                    child: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
                  ),
              ],
            ),
            const SizedBox(height: kPaddingS),
            Text(address.fullAddress, style: theme.textTheme.bodyMedium),
            Text(address.city, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
