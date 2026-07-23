import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:async';
import '../../../constants.dart';
import '../../../services/api_service.dart';
import '../../../services/storage_service.dart';

class OTPPage extends StatefulWidget {
  final String phoneNumber;
  final bool isSeller;
  const OTPPage({super.key, required this.phoneNumber, this.isSeller = false});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  int _counter = 59;
  Timer? _timer;
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("OTP sent successfully!"),
            backgroundColor: colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
          ),
        );
      });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() => _counter--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _handleVerify() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the 6-digit code")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final token = await ApiService.verifyOtp(
      widget.phoneNumber,
      code,
      role: widget.isSeller ? 'admin' : null,
    );

    setState(() => _isLoading = false);

    if (token != null) {
      await StorageService.saveToken(token);
      // Explicitly set the role based on the app flavor/intended use
      await StorageService.saveRole(widget.isSeller ? 'admin' : 'customer');

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid OTP. Please try again.")),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: kPaddingL),
        child: Column(
          children: [
            const SizedBox(height: kPaddingM),
            Text(
              "Verification code",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: kPaddingS),
            Text(
              "Enter the 6-digit that we have sent via the\nphone number ${widget.phoneNumber}",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: kPaddingXL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                (index) => Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: TextField(
                    controller: _controllers[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    decoration: const InputDecoration(
                      counterText: "",
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: kPaddingXL),
            GestureDetector(
              onTap: _counter == 0 ? () {} : null,
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  children: [
                    const TextSpan(text: "Didn't receive your code? "),
                    TextSpan(
                      text: _counter > 0 ? _counter.toString() : "Resend",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleVerify,
                child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text("Verify & Continue"),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

