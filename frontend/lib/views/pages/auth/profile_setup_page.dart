import 'package:flutter/material.dart';
import '../main_screen.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Setup Profile",
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Personal Details",
              style: theme.textTheme.displayLarge?.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              "Please fill in your details to complete your profile.",
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            _buildFieldLabel(context, "First Name"),
            _buildTextField(context, "Enter your first name", Icons.person_outline),
            const SizedBox(height: 20),
            _buildFieldLabel(context, "Last Name", isOptional: true),
            _buildTextField(context, "Enter your last name", Icons.person_outline),
            const SizedBox(height: 20),
            _buildFieldLabel(context, "Email Address"),
            _buildTextField(context, "e.g. name@example.com", Icons.email_outlined),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: colorScheme.primary),
                const SizedBox(width: 4),
                Text(
                  "Required for sending order invoices and updates.",
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildFieldLabel(context, "Date of Birth", isOptional: true),
            _buildDropdownField(context, "Select Date", Icons.calendar_today_outlined),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
                },
                child: const Text("Save Profile"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label, {bool isOptional = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          if (isOptional) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "Optional",
                style: TextStyle(color: colorScheme.primary, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String hint, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: colorScheme.primary.withValues(alpha: 0.5), size: 20),
      ),
    );
  }

  Widget _buildDropdownField(BuildContext context, String hint, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary.withValues(alpha: 0.5), size: 20),
          const SizedBox(width: 12),
          Text(
            hint,
            style: theme.inputDecorationTheme.hintStyle?.copyWith(fontSize: 14),
          ),
          const Spacer(),
          Icon(Icons.keyboard_arrow_down, color: colorScheme.primary),
        ],
      ),
    );
  }
}
