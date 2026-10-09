import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_text_styles.dart';

class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilter;
  final TextEditingController? controller;

  const AppSearchBar({
    super.key,
    this.hintText = 'Search resources, servers, IPs...',
    required this.onChanged,
    this.onFilterTap,
    this.hasActiveFilter = false,
    this.controller,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _controller;
  bool _canClear = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_updateClearButton);
  }

  void _updateClearButton() {
    setState(() {
      _canClear = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: AppRadius.borderMd,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: TextField(
              controller: _controller,
              onChanged: widget.onChanged,
              style: AppTextStyles.bodyMedium(isDark).copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: AppTextStyles.bodyMedium(isDark).copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
                suffixIcon: _canClear
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _controller.clear();
                          widget.onChanged('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        if (widget.onFilterTap != null) ...[
          const SizedBox(width: 8),
          Material(
            color: widget.hasActiveFilter
                ? (isDark ? AppColors.primaryLight : AppColors.primary)
                : (isDark ? AppColors.surfaceDark : Colors.white),
            borderRadius: AppRadius.borderMd,
            child: InkWell(
              onTap: widget.onFilterTap,
              borderRadius: AppRadius.borderMd,
              child: Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.borderMd,
                  border: Border.all(
                    color: widget.hasActiveFilter
                        ? Colors.transparent
                        : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: widget.hasActiveFilter
                      ? Colors.white
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
