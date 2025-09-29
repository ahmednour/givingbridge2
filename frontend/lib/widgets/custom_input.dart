import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';

enum InputVariant { filled, outlined }

enum InputSize { small, medium, large }

class CustomInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final InputVariant variant;
  final InputSize size;
  final bool autofocus;

  const CustomInput({
    Key? key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.focusNode,
    this.inputFormatters,
    this.validator,
    this.variant = InputVariant.filled,
    this.size = InputSize.medium,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _animationController;
  late Animation<double> _borderAnimation;
  bool _hasFocus = false;
  bool _hasContent = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Check initial content
    if (widget.controller != null) {
      _hasContent = widget.controller!.text.isNotEmpty;
      widget.controller!.addListener(_onTextChange);
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    widget.controller?.removeListener(_onTextChange);
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });

    if (_hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onTextChange() {
    final hasContent = widget.controller?.text.isNotEmpty ?? false;
    if (hasContent != _hasContent) {
      setState(() {
        _hasContent = hasContent;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: hasError
                  ? AppTheme.errorColor
                  : (isDark
                      ? AppTheme.darkTextSecondaryColor
                      : AppTheme.textSecondaryColor),
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
        ],

        // Input Field
        AnimatedBuilder(
          animation: _borderAnimation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                boxShadow: _hasFocus && !hasError
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                obscureText: widget.obscureText,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                maxLength: widget.maxLength,
                onTap: widget.onTap,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                onEditingComplete: widget.onEditingComplete,
                inputFormatters: widget.inputFormatters,
                validator: widget.validator,
                autofocus: widget.autofocus,
                style: _getTextStyle(theme, isDark),
                decoration: _getInputDecoration(theme, isDark, hasError),
              ),
            );
          },
        ),

        // Helper/Error Text
        if (widget.helperText != null || widget.errorText != null) ...[
          const SizedBox(height: AppTheme.spacingS),
          Text(
            widget.errorText ?? widget.helperText!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: hasError
                  ? AppTheme.errorColor
                  : (isDark
                      ? AppTheme.textDisabledColor
                      : AppTheme.textDisabledColor),
            ),
          ),
        ],
      ],
    );
  }

  TextStyle _getTextStyle(ThemeData theme, bool isDark) {
    double fontSize;

    switch (widget.size) {
      case InputSize.small:
        fontSize = 14;
        break;
      case InputSize.medium:
        fontSize = 16;
        break;
      case InputSize.large:
        fontSize = 18;
        break;
    }

    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: isDark ? AppTheme.darkTextPrimaryColor : AppTheme.textPrimaryColor,
      height: 1.4,
    );
  }

  InputDecoration _getInputDecoration(
      ThemeData theme, bool isDark, bool hasError) {
    final borderRadius = BorderRadius.circular(AppTheme.radiusM);

    Color fillColor;
    Color borderColor;
    Color focusedBorderColor;

    switch (widget.variant) {
      case InputVariant.filled:
        fillColor =
            isDark ? AppTheme.darkCardColor : AppTheme.cardColor;
        borderColor = Colors.transparent;
        focusedBorderColor =
            hasError ? AppTheme.errorColor : AppTheme.primaryColor;
        break;
      case InputVariant.outlined:
        fillColor = Colors.transparent;
        borderColor = isDark ? AppTheme.darkBorderColor : AppTheme.borderColor;
        focusedBorderColor =
            hasError ? AppTheme.errorColor : AppTheme.primaryColor;
        break;
    }

    if (hasError) {
      borderColor = AppTheme.errorColor;
      focusedBorderColor = AppTheme.errorColor;
    }

    EdgeInsets contentPadding;
    switch (widget.size) {
      case InputSize.small:
        contentPadding = const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: AppTheme.spacingS,
        );
        break;
      case InputSize.medium:
        contentPadding = const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingM,
          vertical: 12.0,
        );
        break;
      case InputSize.large:
        contentPadding = const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: AppTheme.spacingM,
        );
        break;
    }

    return InputDecoration(
      hintText: widget.hint,
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon,
      filled: true,
      fillColor: fillColor,
      contentPadding: contentPadding,
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: focusedBorderColor,
          width: _borderAnimation.value,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(color: AppTheme.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(
          color: AppTheme.errorColor,
          width: 2,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: (isDark ? AppTheme.darkBorderColor : AppTheme.borderColor)
              .withValues(alpha: 0.5),
        ),
      ),
      hintStyle: TextStyle(
        color: isDark ? AppTheme.textDisabledColor : AppTheme.textDisabledColor,
        fontSize: _getTextStyle(theme, isDark).fontSize,
      ),
      counterText: '',
    );
  }
}

// Specialized input widgets
class EmailInput extends CustomInput {
  EmailInput({
    super.key,
    super.label = 'Email',
    super.hint = 'Enter your email',
    super.controller,
    super.onChanged,
    super.validator,
    super.errorText,
    super.enabled,
    super.autofocus,
  }) : super(
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined),
        );
}

class PasswordInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final String? errorText;
  final bool enabled;
  final bool autofocus;

  const PasswordInput({
    super.key,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.controller,
    this.onChanged,
    this.validator,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _obscureText = true;

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomInput(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      onChanged: widget.onChanged,
      validator: widget.validator,
      errorText: widget.errorText,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      obscureText: _obscureText,
      prefixIcon: const Icon(Icons.lock_outlined),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
        onPressed: _toggleObscureText,
        tooltip: _obscureText ? 'Show password' : 'Hide password',
      ),
    );
  }
}

class SearchInput extends CustomInput {
  SearchInput({
    super.key,
    super.hint = 'Search...',
    super.controller,
    super.onChanged,
    super.onSubmitted,
    VoidCallback? onClear,
  }) : super(
          prefixIcon: const Icon(Icons.search_outlined),
          suffixIcon: onClear != null
              ? IconButton(
                  icon: const Icon(Icons.clear_outlined),
                  onPressed: onClear,
                  tooltip: 'Clear search',
                )
              : null,
        );
}

class TextAreaInput extends CustomInput {
  TextAreaInput({
    super.key,
    super.label,
    super.hint,
    super.controller,
    super.onChanged,
    super.validator,
    super.errorText,
    super.helperText,
    super.enabled,
    super.maxLength,
    int minLines = 3,
    int maxLines = 6,
  }) : super(
          maxLines: maxLines,
          keyboardType: TextInputType.multiline,
        );
}
