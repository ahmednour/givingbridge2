import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/design_system.dart';

/// Enhanced TextField Component for GivingBridge
/// Features: Material 3 design, password toggle, validation states, helper text
class GBTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool showCounter;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;

  const GBTextField({
    Key? key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showCounter = false,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
  }) : super(key: key);

  @override
  State<GBTextField> createState() => _GBTextFieldState();
}

class _GBTextFieldState extends State<GBTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _obscureText = false;
  String? _currentError;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  Widget? _buildSuffixIcon() {
    // Password visibility toggle takes priority
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          color: _isFocused
              ? DesignSystem.primaryBlue
              : DesignSystem.textSecondary,
          size: DesignSystem.iconSizeMedium,
        ),
        onPressed: _toggleObscureText,
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      );
    }
    return widget.suffixIcon;
  }

  Color _getBorderColor() {
    if (!widget.enabled) {
      return DesignSystem.border;
    }
    if (_currentError != null || widget.errorText != null) {
      return DesignSystem.error;
    }
    if (_isFocused) {
      return DesignSystem.primaryBlue;
    }
    return DesignSystem.border;
  }

  double _getBorderWidth() {
    if (_currentError != null || widget.errorText != null) {
      return 2;
    }
    if (_isFocused) {
      return 2;
    }
    return 1.5;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _currentError != null || widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: DesignSystem.labelMedium(context).copyWith(
              color: hasError
                  ? DesignSystem.error
                  : _isFocused
                      ? DesignSystem.primaryBlue
                      : DesignSystem.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: DesignSystem.spaceS),
        ],

        // Text Field
        AnimatedContainer(
          duration: DesignSystem.shortDuration,
          curve: DesignSystem.defaultCurve,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            boxShadow: _isFocused ? DesignSystem.elevation1 : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            obscureText: _obscureText,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            style: DesignSystem.bodyMedium(context),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: DesignSystem.bodyMedium(context).copyWith(
                color: DesignSystem.textTertiary,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                        color: _isFocused
                            ? DesignSystem.primaryBlue
                            : DesignSystem.textSecondary,
                        size: DesignSystem.iconSizeMedium,
                      ),
                      child: widget.prefixIcon!,
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(),
              filled: true,
              fillColor: widget.enabled
                  ? DesignSystem.surfaceLight
                  : DesignSystem.neutral100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DesignSystem.spaceL,
                vertical: DesignSystem.spaceM,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                borderSide: BorderSide(
                  color: _getBorderColor(),
                  width: _getBorderWidth(),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                borderSide: BorderSide(
                  color: _getBorderColor(),
                  width: _getBorderWidth(),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                borderSide: BorderSide(
                  color: _getBorderColor(),
                  width: _getBorderWidth(),
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                borderSide: const BorderSide(
                  color: DesignSystem.error,
                  width: 2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                borderSide: const BorderSide(
                  color: DesignSystem.error,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                borderSide: const BorderSide(
                  color: DesignSystem.border,
                  width: 1.5,
                ),
              ),
              counterText: widget.showCounter ? null : '',
              errorText: null, // We'll show error text separately
            ),
            validator: (value) {
              final error = widget.validator?.call(value);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _currentError = error;
                  });
                }
              });
              return error;
            },
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
          ),
        ),

        // Helper text or Error text
        if (widget.helperText != null || hasError) ...[
          const SizedBox(height: DesignSystem.spaceS),
          AnimatedSwitcher(
            duration: DesignSystem.shortDuration,
            child: Row(
              key: ValueKey(hasError),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasError) ...[
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: DesignSystem.error,
                  ),
                  const SizedBox(width: DesignSystem.spaceXS),
                ],
                Expanded(
                  child: Text(
                    hasError
                        ? (widget.errorText ?? _currentError ?? '')
                        : widget.helperText ?? '',
                    style: DesignSystem.bodySmall(context).copyWith(
                      color: hasError
                          ? DesignSystem.error
                          : DesignSystem.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Password strength meter widget
class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({Key? key, required this.password})
      : super(key: key);

  int _calculateStrength() {
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
    if (RegExp(r'[a-z]').hasMatch(password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;
    return (strength / 6 * 4).round(); // Normalize to 0-4
  }

  String _getStrengthLabel(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Strong';
      default:
        return 'Weak';
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return DesignSystem.error;
      case 2:
        return DesignSystem.warning;
      case 3:
        return DesignSystem.info;
      case 4:
        return DesignSystem.success;
      default:
        return DesignSystem.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = _calculateStrength();
    final color = _getStrengthColor(strength);
    final label = _getStrengthLabel(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: DesignSystem.spaceS),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                child: LinearProgressIndicator(
                  value: strength / 4,
                  backgroundColor: DesignSystem.neutral200,
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: DesignSystem.spaceS),
            Text(
              label,
              style: DesignSystem.bodySmall(context).copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
