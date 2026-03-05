import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_theme.dart';
import '../../services/haptic_service.dart';

/// Shows the phone + OTP dialog over whatever screen is currently displayed.
/// Returns the verified phone number string, or null if the user skipped.
Future<String?> showPhoneOtpDialog(BuildContext context) {
  return showDialog<String?>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _PhoneOtpDialog(),
  );
}

class _PhoneOtpDialog extends StatefulWidget {
  const _PhoneOtpDialog();

  @override
  State<_PhoneOtpDialog> createState() => _PhoneOtpDialogState();
}

class _PhoneOtpDialogState extends State<_PhoneOtpDialog> {
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();
  bool get _hasNumber => _phoneController.text.trim().length == 10;

  bool _showOtp = false;
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  bool get _otpComplete => _otpControllers.every((c) => c.text.length == 1);

  void _goToOtp() {
    HapticService.tap();
    setState(() => _showOtp = true);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _otpFocusNodes.first.requestFocus(),
    );
  }

  void _verify() {
    HapticService.tap();
    Navigator.pop(context, _phoneController.text.trim());
  }

  void _skip() {
    HapticService.tap();
    Navigator.pop(context, null);
  }

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(() => setState(() {}));
    for (final c in _otpControllers) {
      c.addListener(() => setState(() {}));
    }
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _phoneFocus.requestFocus(),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    for (final c in _otpControllers) { c.dispose(); }
    for (final f in _otpFocusNodes) { f.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      insetPadding: const EdgeInsets.all(40),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pine Labs logo
              SvgPicture.asset(
                'images/logo/pinelabs_logo.svg',
                height: 20,
                colorFilter: const ColorFilter.mode(AppTheme.brandGreen, BlendMode.srcIn),
              ),
              const SizedBox(height: 28),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showOtp
                    ? _OtpContent(
                        key: const ValueKey('otp'),
                        phone: _phoneController.text.trim(),
                        controllers: _otpControllers,
                        focusNodes: _otpFocusNodes,
                        otpComplete: _otpComplete,
                        onVerify: _verify,
                        onChangeNumber: () {
                          HapticService.tap();
                          setState(() {
                            _showOtp = false;
                            for (final c in _otpControllers) { c.clear(); }
                          });
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _phoneFocus.requestFocus(),
                          );
                        },
                        tt: tt,
                        cs: cs,
                      )
                    : _PhoneContent(
                        key: const ValueKey('phone'),
                        controller: _phoneController,
                        focusNode: _phoneFocus,
                        hasNumber: _hasNumber,
                        onContinue: _goToOtp,
                        onSkip: _skip,
                        tt: tt,
                        cs: cs,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Phone entry ───────────────────────────────────────────────────────────────

class _PhoneContent extends StatelessWidget {
  const _PhoneContent({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hasNumber,
    required this.onContinue,
    required this.onSkip,
    required this.tt,
    required this.cs,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasNumber;
  final VoidCallback onContinue;
  final VoidCallback onSkip;
  final TextTheme tt;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Login to see\ngreat offers',
          style: tt.displaySmall?.copyWith(
            color: AppTheme.brandGreen,
            fontWeight: FontWeight.w500,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enter your mobile number to continue.',
          style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 40),
        _PhoneField(controller: controller, focusNode: focusNode, tt: tt, cs: cs),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onSkip,
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.onSurfaceVariant,
                  side: BorderSide(color: cs.outlineVariant, width: 1.5),
                  fixedSize: const Size.fromHeight(56),
                  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
                child: const Text('Skip'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: hasNumber ? onContinue : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.brandGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: cs.surfaceContainerHighest,
                  disabledForegroundColor: cs.onSurfaceVariant.withAlpha(100),
                  fixedSize: const Size.fromHeight(56),
                  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PhoneField extends StatelessWidget {
  const _PhoneField({
    required this.controller,
    required this.focusNode,
    required this.tt,
    required this.cs,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final TextTheme tt;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([controller, focusNode]),
      builder: (context, _) {
        final hasNumber = controller.text.trim().length == 10;
        return Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: focusNode.hasFocus ? AppTheme.brandGreen : cs.outlineVariant,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '+91',
                  style: tt.titleLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(width: 1, height: 36, color: cs.outlineVariant),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: tt.headlineSmall?.copyWith(
                    color: cs.onSurface,
                    letterSpacing: 3,
                  ),
                  decoration: InputDecoration(
                    hintText: '00000 00000',
                    hintStyle: tt.headlineSmall?.copyWith(
                      color: cs.onSurface.withAlpha(40),
                      letterSpacing: 3,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
              if (hasNumber)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.brandGreen,
                    size: 28,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── OTP entry ─────────────────────────────────────────────────────────────────

class _OtpContent extends StatelessWidget {
  const _OtpContent({
    super.key,
    required this.phone,
    required this.controllers,
    required this.focusNodes,
    required this.otpComplete,
    required this.onVerify,
    required this.onChangeNumber,
    required this.tt,
    required this.cs,
  });

  final String phone;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool otpComplete;
  final VoidCallback onVerify;
  final VoidCallback onChangeNumber;
  final TextTheme tt;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter OTP',
          style: tt.displaySmall?.copyWith(
            color: AppTheme.brandGreen,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        RichText(
          text: TextSpan(
            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            children: [
              const TextSpan(text: 'OTP sent to '),
              TextSpan(
                text: '+91 ${phone.substring(0, 5)} ${phone.substring(5)}',
                style: TextStyle(
                  color: AppTheme.brandGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            6,
            (i) => _OtpBox(
              controller: controllers[i],
              focusNode: focusNodes[i],
              nextFocus: i < 5 ? focusNodes[i + 1] : null,
              prevFocus: i > 0 ? focusNodes[i - 1] : null,
              prevController: i > 0 ? controllers[i - 1] : null,
              tt: tt,
              cs: cs,
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onChangeNumber,
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.onSurfaceVariant,
                  side: BorderSide(color: cs.outlineVariant, width: 1.5),
                  fixedSize: const Size.fromHeight(56),
                  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
                child: const Text('Change No.'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: otpComplete ? onVerify : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.brandGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: cs.surfaceContainerHighest,
                  disabledForegroundColor: cs.onSurfaceVariant.withAlpha(100),
                  fixedSize: const Size.fromHeight(56),
                  textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                ),
                child: const Text('Verify & Continue'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.tt,
    required this.cs,
    this.nextFocus,
    this.prevFocus,
    this.prevController,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final FocusNode? prevFocus;
  final TextEditingController? prevController;
  final TextTheme tt;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) {
        return Container(
          width: 68,
          height: 64,
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: focusNode.hasFocus ? AppTheme.brandGreen : cs.outlineVariant,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: tt.headlineMedium?.copyWith(
              color: AppTheme.brandGreen,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 16),
            ),
            onChanged: (v) {
              if (v.isNotEmpty) {
                nextFocus?.requestFocus();
              } else {
                prevController?.clear();
                prevFocus?.requestFocus();
              }
            },
          ),
        );
      },
    );
  }
}
