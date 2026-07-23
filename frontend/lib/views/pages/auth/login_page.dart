import 'package:flutter/material.dart';
import 'otp_page.dart';
import '../../../constants.dart';
import '../../../services/api_service.dart';

class LoginPage extends StatefulWidget {
  final bool isSeller;

  const LoginPage({super.key, this.isSeller = false});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleGetOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid phone number")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final success = await ApiService.requestOtp(phone);
      if (success) {
        print("isSeller :: ${widget.isSeller}");
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPPage(
                phoneNumber: phone,
                isSeller: widget.isSeller,
              ),
            ),
          );
        }
      } else {
        throw Exception("Failed to send OTP");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to send OTP. Please try again.")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: widget.isSeller
            ? []
            : [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text("Skip"),
                ),
                const SizedBox(width: kPaddingM),
              ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: kPaddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: kPaddingM),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: Icon(Icons.bakery_dining, size: 60, color: colorScheme.primary),
              ),
            ),
            const SizedBox(height: kPaddingM),
            Text(
              "ANNAMALAIYAR",
              style: theme.textTheme.displayMedium?.copyWith(
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 60),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isSeller ? "Welcome Admin" : "Welcome",
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: kPaddingS),
                  Text(
                    widget.isSeller ? "Log in to manage your store" : "Log in to your account",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kPaddingXL),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: "Mobile number",
                prefixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: kPaddingM, vertical: 14),
                  child: Text(
                    "+91",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: kPaddingM),
            Text(
              "You will receive an SMS verification that may apply message and data rates.",
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 80),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleGetOtp,
                child: _isLoading 
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("Get OTP"),
              ),
            ),
            const SizedBox(height: kPaddingL),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                children: [
                  const TextSpan(text: "By continuing, you agree to our "),
                  TextSpan(
                    text: "Terms and Conditions",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: " and "),
                  TextSpan(
                    text: "Privacy Policy",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kPaddingL),
          ],
        ),
      ),
    );
  }
}
