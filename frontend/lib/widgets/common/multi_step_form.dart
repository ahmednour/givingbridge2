import 'package:flutter/material.dart';
import '../../core/theme/app_theme_enhanced.dart';
import '../../core/utils/rtl_utils.dart';
import '../../core/constants/ui_constants.dart';
import '../app_components.dart';
import '../../l10n/app_localizations.dart';

class MultiStepForm extends StatefulWidget {
  final List<Widget> steps;
  final List<String> stepTitles;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;
  final String submitText;
  final String cancelText;
  final IconData? submitIcon;
  final bool showProgressIndicator;
  final bool allowStepNavigation;

  const MultiStepForm({
    Key? key,
    required this.steps,
    required this.stepTitles,
    this.onSubmit,
    this.onCancel,
    this.isLoading = false,
    this.submitText = 'Submit',
    this.cancelText = 'Cancel',
    this.submitIcon,
    this.showProgressIndicator = true,
    this.allowStepNavigation = true,
  }) : super(key: key);

  @override
  State<MultiStepForm> createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressAnimationController;

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < widget.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress Indicator
        if (widget.showProgressIndicator) _buildProgressIndicator(),

        // Step Content
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentStep = index;
              });
            },
            children: widget.steps,
          ),
        ),

        // Navigation Buttons
        _buildNavigationButtons(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: EdgeInsets.all(UIConstants.spacingM),
      child: Column(
        children: [
          // Progress Bar
          Row(
            children: List.generate(widget.steps.length, (index) {
              final isActive = index <= _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.primaryColor
                              : AppTheme.borderColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < widget.steps.length - 1)
                      AppSpacing.horizontal(UIConstants.spacingXS),
                  ],
                ),
              );
            }),
          ),

          AppSpacing.vertical(UIConstants.spacingS),

          // Step Counter
          Text(
            '${_currentStep + 1} of ${widget.steps.length}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),

          // Step Titles (if provided)
          if (widget.stepTitles.isNotEmpty) ...[
            AppSpacing.vertical(UIConstants.spacingS),
            Text(
              widget.stepTitles[_currentStep],
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(UIConstants.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          if (_currentStep > 0)
            Expanded(
              child: AppButton(
                text: l10n.previous,
                type: AppButtonType.secondary,
                onPressed: _previousStep,
                icon: RTLUtils.getDirectionalIcon(
                  context,
                  Icons.arrow_back,
                  start: Icons.arrow_back,
                  end: Icons.arrow_forward,
                ),
              ),
            ),

          if (_currentStep > 0) AppSpacing.horizontal(UIConstants.spacingM),

          // Cancel Button (if provided)
          if (widget.onCancel != null && _currentStep == 0)
            Expanded(
              child: AppButton(
                text: widget.cancelText,
                type: AppButtonType.text,
                onPressed: widget.onCancel,
              ),
            ),

          if (widget.onCancel != null && _currentStep == 0)
            AppSpacing.horizontal(UIConstants.spacingM),

          // Next/Submit Button
          Expanded(
            flex: _currentStep == 0 && widget.onCancel != null ? 1 : 2,
            child: AppButton(
              text: _currentStep == widget.steps.length - 1
                  ? widget.submitText
                  : l10n.next,
              onPressed: widget.isLoading
                  ? null
                  : (_currentStep == widget.steps.length - 1
                      ? widget.onSubmit
                      : _nextStep),
              isLoading:
                  widget.isLoading && _currentStep == widget.steps.length - 1,
              icon: _currentStep == widget.steps.length - 1
                  ? widget.submitIcon
                  : RTLUtils.getDirectionalIcon(
                      context,
                      Icons.arrow_forward,
                      start: Icons.arrow_forward,
                      end: Icons.arrow_back,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? stepTitles;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;
  final double spacing;

  const StepIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.stepTitles,
    this.activeColor,
    this.inactiveColor,
    this.height = 4.0,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeColor = this.activeColor ?? AppTheme.primaryColor;
    final inactiveColor = this.inactiveColor ?? AppTheme.borderColor;

    return Column(
      children: [
        // Progress Bar
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index <= currentStep;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: height,
                      decoration: BoxDecoration(
                        color: isActive ? activeColor : inactiveColor,
                        borderRadius: BorderRadius.circular(height / 2),
                      ),
                    ),
                  ),
                  if (index < totalSteps - 1) SizedBox(width: spacing),
                ],
              ),
            );
          }),
        ),

        // Step Counter
        SizedBox(height: UIConstants.spacingS),
        Text(
          '${currentStep + 1} of $totalSteps',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
        ),

        // Step Titles
        if (stepTitles != null && stepTitles!.isNotEmpty) ...[
          SizedBox(height: UIConstants.spacingS),
          Text(
            stepTitles![currentStep],
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class StepNavigationButtons extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;
  final VoidCallback? onCancel;
  final bool isLoading;
  final String? previousText;
  final String? nextText;
  final String? submitText;
  final String? cancelText;
  final IconData? previousIcon;
  final IconData? nextIcon;
  final IconData? submitIcon;

  const StepNavigationButtons({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.onPrevious,
    this.onNext,
    this.onSubmit,
    this.onCancel,
    this.isLoading = false,
    this.previousText,
    this.nextText,
    this.submitText,
    this.cancelText,
    this.previousIcon,
    this.nextIcon,
    this.submitIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(UIConstants.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          if (currentStep > 0 && onPrevious != null)
            Expanded(
              child: AppButton(
                text: previousText ?? l10n.previous,
                type: AppButtonType.secondary,
                onPressed: onPrevious,
                icon: previousIcon ??
                    RTLUtils.getDirectionalIcon(
                      context,
                      Icons.arrow_back,
                      start: Icons.arrow_back,
                      end: Icons.arrow_forward,
                    ),
              ),
            ),

          if (currentStep > 0 && onPrevious != null)
            AppSpacing.horizontal(UIConstants.spacingM),

          // Cancel Button
          if (onCancel != null && currentStep == 0)
            Expanded(
              child: AppButton(
                text: cancelText ?? l10n.cancel,
                type: AppButtonType.text,
                onPressed: onCancel,
              ),
            ),

          if (onCancel != null && currentStep == 0)
            AppSpacing.horizontal(UIConstants.spacingM),

          // Next/Submit Button
          Expanded(
            flex: (currentStep == 0 && onCancel != null) ? 1 : 2,
            child: AppButton(
              text: currentStep == totalSteps - 1
                  ? (submitText ?? l10n.submit)
                  : (nextText ?? l10n.next),
              onPressed: isLoading
                  ? null
                  : (currentStep == totalSteps - 1 ? onSubmit : onNext),
              isLoading: isLoading && currentStep == totalSteps - 1,
              icon: currentStep == totalSteps - 1
                  ? submitIcon
                  : (nextIcon ??
                      RTLUtils.getDirectionalIcon(
                        context,
                        Icons.arrow_forward,
                        start: Icons.arrow_forward,
                        end: Icons.arrow_back,
                      )),
            ),
          ),
        ],
      ),
    );
  }
}
