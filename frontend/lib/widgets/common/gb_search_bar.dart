import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/design_system.dart';

/// Enhanced Search Bar with Autocomplete for GivingBridge
class GBSearchBar<T> extends StatefulWidget {
  final String hint;
  final Function(String) onSearch;
  final Function(String)? onChanged;
  final Function(T)? onSuggestionSelected;
  final Future<List<T>> Function(String)? fetchSuggestions;
  final String Function(T)? suggestionBuilder;
  final Widget Function(T)? suggestionItemBuilder;
  final bool showSuggestions;
  final Duration debounceDuration;
  final TextEditingController? controller;
  final bool autofocus;

  const GBSearchBar({
    Key? key,
    required this.hint,
    required this.onSearch,
    this.onChanged,
    this.onSuggestionSelected,
    this.fetchSuggestions,
    this.suggestionBuilder,
    this.suggestionItemBuilder,
    this.showSuggestions = true,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.controller,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<GBSearchBar<T>> createState() => _GBSearchBarState<T>();
}

class _GBSearchBarState<T> extends State<GBSearchBar<T>> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  List<T> _suggestions = [];
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    _debounce?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && _controller.text.isNotEmpty) {
      _searchAndShowSuggestions(_controller.text);
    } else {
      _removeOverlay();
    }
  }

  void _onTextChanged(String query) {
    widget.onChanged?.call(query);

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(widget.debounceDuration, () {
      if (query.isEmpty) {
        _removeOverlay();
      } else {
        _searchAndShowSuggestions(query);
      }
    });
  }

  Future<void> _searchAndShowSuggestions(String query) async {
    if (!widget.showSuggestions || widget.fetchSuggestions == null) return;

    setState(() => _isLoading = true);

    try {
      final suggestions = await widget.fetchSuggestions!(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });

        if (suggestions.isNotEmpty) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _getSearchBarWidth(),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, _getSearchBarHeight() + 8),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(DesignSystem.radiusL),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: DesignSystem.getSurfaceColor(context),
                borderRadius: BorderRadius.circular(DesignSystem.radiusL),
                border: Border.all(
                  color: DesignSystem.getBorderColor(context),
                ),
                boxShadow: DesignSystem.elevation3,
              ),
              child: _buildSuggestionsList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _getSearchBarWidth() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 300;
  }

  double _getSearchBarHeight() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.height ?? 48;
  }

  Widget _buildSuggestionsList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(DesignSystem.spaceL),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: DesignSystem.spaceS),
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];

        if (widget.suggestionItemBuilder != null) {
          return InkWell(
            onTap: () => _selectSuggestion(suggestion),
            child: widget.suggestionItemBuilder!(suggestion),
          );
        }

        final text =
            widget.suggestionBuilder?.call(suggestion) ?? suggestion.toString();

        return ListTile(
          leading: const Icon(Icons.search, size: 20),
          title: Text(
            text,
            style: DesignSystem.bodyMedium(context),
          ),
          onTap: () => _selectSuggestion(suggestion),
        );
      },
    );
  }

  void _selectSuggestion(T suggestion) {
    final text =
        widget.suggestionBuilder?.call(suggestion) ?? suggestion.toString();
    _controller.text = text;
    widget.onSuggestionSelected?.call(suggestion);
    widget.onSearch(text);
    _removeOverlay();
    _focusNode.unfocus();
  }

  void _handleSearch() {
    widget.onSearch(_controller.text);
    _removeOverlay();
    _focusNode.unfocus();
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          boxShadow: _focusNode.hasFocus
              ? DesignSystem.elevation2
              : DesignSystem.elevation1,
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          style: DesignSystem.bodyMedium(context),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: DesignSystem.bodyMedium(context).copyWith(
              color: DesignSystem.textTertiary,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: _focusNode.hasFocus
                  ? DesignSystem.primaryBlue
                  : DesignSystem.textSecondary,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(DesignSystem.spaceM),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                          iconSize: 20,
                          color: DesignSystem.textSecondary,
                        ),
                    ],
                  )
                : null,
            filled: true,
            fillColor: DesignSystem.getSurfaceColor(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DesignSystem.spaceL,
              vertical: DesignSystem.spaceM,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              borderSide: BorderSide(
                color: DesignSystem.getBorderColor(context),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              borderSide: BorderSide(
                color: DesignSystem.getBorderColor(context),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(DesignSystem.radiusL),
              borderSide: const BorderSide(
                color: DesignSystem.primaryBlue,
                width: 2,
              ),
            ),
          ),
          onChanged: _onTextChanged,
          onSubmitted: (_) => _handleSearch(),
          textInputAction: TextInputAction.search,
        ),
      ),
    );
  }
}

/// Donation search model for autocomplete
class DonationSearchResult {
  final int id;
  final String title;
  final String category;

  DonationSearchResult({
    required this.id,
    required this.title,
    required this.category,
  });
}

/// Usage Examples:
/// 
/// // Basic search
/// GBSearchBar<String>(
///   hint: 'Search donations...',
///   onSearch: (query) => _performSearch(query),
/// )
/// 
/// // With autocomplete
/// GBSearchBar<DonationSearchResult>(
///   hint: 'Search donations...',
///   onSearch: (query) => _performSearch(query),
///   fetchSuggestions: (query) async {
///     return await ApiService.searchDonations(query);
///   },
///   suggestionBuilder: (result) => result.title,
///   onSuggestionSelected: (result) => _navigateToDonation(result.id),
/// )
/// 
/// // Custom suggestion item
/// GBSearchBar<DonationSearchResult>(
///   hint: 'Search...',
///   onSearch: _search,
///   fetchSuggestions: _fetchSuggestions,
///   suggestionItemBuilder: (result) => ListTile(
///     leading: Icon(_getCategoryIcon(result.category)),
///     title: Text(result.title),
///     subtitle: Text(result.category),
///   ),
/// )
