import 'package:flutter/material.dart';
import '../main_screen.dart';
import '../../../constants.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: kCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Setup Profile",
          style: TextStyle(color: kText, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Personal Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText),
            ),
            const SizedBox(height: 8),
            Text(
              "Please fill in your details to complete your profile.",
              style: TextStyle(color: kTextMuted, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildFieldLabel("First Name"),
            _buildTextField("Enter your first name", Icons.person_outline),
            const SizedBox(height: 20),
            _buildFieldLabel("Last Name", isOptional: true),
            _buildTextField("Enter your last name", Icons.person_outline),
            const SizedBox(height: 20),
            _buildFieldLabel("Email Address"),
            _buildTextField("e.g. name@example.com", Icons.email_outlined),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: kGold),
                const SizedBox(width: 4),
                Text(
                  "Required for sending order invoices and updates.",
                  style: TextStyle(color: kTextMuted, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildFieldLabel("Date of Birth", isOptional: true),
            _buildDropdownField("Select Date", Icons.calendar_today_outlined),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  "Save Profile",
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kText),
          ),
          if (isOptional) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: kGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "Optional",
                style: TextStyle(color: kGold, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: kTextMuted.withValues(alpha: 0.5), fontSize: 14),
        prefixIcon: Icon(icon, color: kGold.withValues(alpha: 0.5), size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kGold.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: kGold.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kGold),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kGold.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: kGold.withValues(alpha: 0.5), size: 20),
          const SizedBox(width: 12),
          Text(hint, style: TextStyle(color: kTextMuted.withValues(alpha: 0.5), fontSize: 14)),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_down, color: kGold),
        ],
      ),
    );
  }
}

