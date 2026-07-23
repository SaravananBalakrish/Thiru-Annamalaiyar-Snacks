import 'package:flutter/material.dart';

import 'map_picker_page.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controllers/address_controller.dart';
import '../../models/address.dart';

class SavedAddressesPage extends StatefulWidget {
  const SavedAddressesPage({super.key});

  @override
  State<SavedAddressesPage> createState() => _SavedAddressesPageState();
}

class _SavedAddressesPageState extends State<SavedAddressesPage> {

  @override
  void initState() {
    // TODO: implement initState
    if(mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AddressController>().loadAddresses();
      });
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(kSavedAddresses,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Consumer<AddressController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null && controller.addresses.isEmpty) {
            return _buildErrorState(theme, colorScheme, controller);
          }

          if (controller.addresses.isEmpty) {
            return _buildEmptyState(theme, colorScheme, context);
          }

          return Stack(
            children: [
              ListView.builder(
                padding: const EdgeInsets.all(kPaddingM),
                itemCount: controller.addresses.length,
                itemBuilder: (context, index) {
                  final address = controller.addresses[index];
                  return _AddressCard(
                    address: address,
                    theme: theme,
                    colorScheme: colorScheme,
                  );
                },
              ),
              if (controller.isLoading)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToMapPicker(context),
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

  Widget _buildErrorState(ThemeData theme, ColorScheme colorScheme, AddressController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kPaddingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: colorScheme.error),
            const SizedBox(height: kPaddingM),
            Text(
              controller.error ?? "Something went wrong",
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: kPaddingL),
            ElevatedButton(
              onPressed: () => controller.loadAddresses(),
              child: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _navigateToMapPicker(BuildContext context, {Address? address}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MapPickerPage(address: address)),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(address != null ? "Address updated successfully" : "Address saved successfully")),
      );
    }
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _AddressCard({
    required this.address,
    required this.theme,
    required this.colorScheme,
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () {
                        context.findAncestorStateOfType<_SavedAddressesPageState>()
                            ?._navigateToMapPicker(context, address: address);
                      },
                      visualDensity: VisualDensity.compact,
                      tooltip: "Edit",
                    ),
                    if (!address.isDefault)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        onPressed: () {
                          context.read<AddressController>().setDefault(address.id);
                        },
                        visualDensity: VisualDensity.compact,
                        tooltip: "Set as Default",
                      ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 20, color: colorScheme.error),
                      onPressed: () {
                        context.read<AddressController>().deleteAddress(address.id);
                      },
                      visualDensity: VisualDensity.compact,
                      tooltip: "Delete",
                    ),
                  ],
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
