import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Interactive date range selector widget with preset options
/// 
/// Features:
/// - Custom date range selection with start and end date pickers
/// - Preset quick selection buttons (This Week, This Month, etc.)
/// - Horizontal scrollable preset chips with selection state
/// - Date range picker integration for easy range selection
/// - Automatic end-of-day time adjustment for accurate filtering
/// - Callback system for parent widget communication
/// - Material Design 3 compliant styling and theming
/// - Responsive design with proper overflow handling
class DateRangeSelector extends StatefulWidget {
  final DateTimeRange? initialRange;
  final ValueChanged<DateTimeRange> onChanged;
  final List<String>? presetLabels;

  /// Creates a date range selector with preset options
  /// 
  /// Parameters:
  /// - [initialRange]: Optional initial date range (defaults to current month)
  /// - [onChanged]: Required callback when date range changes
  /// - [presetLabels]: Optional custom preset labels (uses defaults if null)
  const DateRangeSelector({
    super.key,
    this.initialRange,
    required this.onChanged,
    this.presetLabels,
  });

  @override
  State<DateRangeSelector> createState() => _DateRangeSelectorState();
}

/// Stateful widget implementation with date range management
class _DateRangeSelectorState extends State<DateRangeSelector> {
  late DateTimeRange _currentRange;
  String? _selectedPreset;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Default to current month if no initial range provided
    _currentRange = widget.initialRange ??
        DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
  }

  @override
  Widget build(BuildContext context) {
    final presets = widget.presetLabels ?? _defaultPresets;
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom date range selector
        _CustomRangeSelector(
          range: _currentRange,
          onStartDatePressed: () => _selectDate(true),
          onEndDatePressed: () => _selectDate(false),
          onRangePressed: _selectRange,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Preset buttons
              ...presets.map((label) {
                return _PresetButton(
                  label: label,
                  onPressed: () => _handlePresetSelection(label, now),
                  selected: _selectedPreset == label,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  /// Handles preset button selection and calculates corresponding date ranges
  /// 
  /// Parameters:
  /// - [label]: Preset label (e.g., "This Week", "This Month")
  /// - [now]: Current DateTime for relative calculations
  /// 
  /// Calculates appropriate date ranges based on preset selection and
  /// updates the current range through _updateRange method.
  void _handlePresetSelection(String label, DateTime now) {
    setState(() => _selectedPreset = label);

    DateTimeRange newRange;

    switch (label) {
      case 'Today':
        newRange = DateTimeRange(start: now, end: now);
        break;
      case 'This Week':
        newRange = DateTimeRange(
          // start: now.subtract(Duration(days: now.weekday - 1)),
          start: DateTime(now.year, now.month, now.day - 6),
          end: now,
        );
        break;
      case 'This Month':
        newRange = DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
        break;
      case 'Last 3 Months':
        newRange = DateTimeRange(
          start: DateTime(now.year, now.month - 2, 1),
          end: now,
        );
        break;
      case 'Last 6 Months':
        newRange = DateTimeRange(
          start: DateTime(now.year, now.month - 5, 1),
          end: now,
        );
        break;
      case 'This Year':
        newRange = DateTimeRange(
          start: DateTime(now.year, 1, 1),
          end: now,
        );
        break;
      default:
        return;
    }

    _updateRange(newRange);
    setState(() => _selectedPreset = label);
  }

  /// Shows date picker for individual start or end date selection
  /// 
  /// Parameters:
  /// - [isStart]: true for start date, false for end date
  /// 
  /// Opens native date picker and updates the range while preserving
  /// the other date. Automatically sets end time to end-of-day.
  Future<void> _selectDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _currentRange.start : _currentRange.end,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && mounted) {
      final newRange = isStart
          ? DateTimeRange(start: picked, end: _currentRange.end)
          : DateTimeRange(
              start: _currentRange.start,
              end: DateTime(
                  picked.year, picked.month, picked.day, 23, 59, 59, 999));
      _updateRange(newRange);
    }
  }

  /// Shows date range picker for selecting both start and end dates
  /// 
  /// Opens native date range picker with current range as initial selection.
  /// Automatically adjusts end date to end-of-day for accurate filtering.
  Future<void> _selectRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: _currentRange,
    );

    if (picked != null && mounted) {
      final adjustedRange = DateTimeRange(
        start:
            DateTime(picked.start.year, picked.start.month, picked.start.day),
        end: DateTime(
            picked.end.year, picked.end.month, picked.end.day, 23, 59, 59, 999),
      );
      _updateRange(adjustedRange);
    }
  }

  /// Updates the current range and notifies parent widget
  /// 
  /// Parameters:
  /// - [newRange]: New DateTimeRange to set
  /// 
  /// Updates internal state, clears preset selection for custom ranges,
  /// and calls the onChanged callback to notify parent widget.
  void _updateRange(DateTimeRange newRange) {
    setState(() {
      _currentRange = newRange;
      _selectedPreset = null; // Clear preset selection when using custom range
    });
    widget.onChanged(newRange);
  }

  /// Default preset options for quick date range selection
  /// 
  /// Provides commonly used date ranges for business analytics:
  /// - This Week: Last 7 days including today
  /// - This Month: From first day of current month to today
  /// - Last 6 Months: From 6 months ago to today
  /// - This Year: From January 1st to today
  static const _defaultPresets = [
    // 'Today',
    'This Week',
    'This Month',
    // 'Last 3 Months',
    'Last 6 Months',
    'This Year',
  ];
}

/// Preset button widget for quick date range selection
/// 
/// Features:
/// - ChoiceChip design with selection state indication
/// - Theme-aware styling with proper contrast
/// - Compact design suitable for horizontal scrolling
/// - Material Design 3 compliance with rounded corners
class _PresetButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;

  /// Creates a preset selection button
  /// 
  /// Parameters:
  /// - [label]: Button text (e.g., "This Week", "This Month")
  /// - [selected]: Whether this preset is currently selected
  /// - [onPressed]: Callback when button is tapped
  const _PresetButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onPressed(),
        labelStyle: TextStyle(
          fontSize: 12,
          color: selected
              ? theme.colorScheme.onPrimary
              : theme.textTheme.bodyMedium?.color,
        ),
        selectedColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        showCheckmark: false,
        side: BorderSide(
          color: theme.colorScheme.outline,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
    );
  }
}

/// Custom date range selector widget with individual date buttons
/// 
/// Features:
/// - Calendar icon for opening date range picker
/// - Individual start and end date buttons with formatted display
/// - Bordered container with dividers for visual separation
/// - Compact horizontal layout with proper spacing
/// - Tooltip support for accessibility
class _CustomRangeSelector extends StatelessWidget {
  final DateTimeRange range;
  final VoidCallback onStartDatePressed;
  final VoidCallback onEndDatePressed;
  final VoidCallback onRangePressed;

  /// Creates a custom range selector with individual date controls
  /// 
  /// Parameters:
  /// - [range]: Current date range to display
  /// - [onStartDatePressed]: Callback for start date button
  /// - [onEndDatePressed]: Callback for end date button
  /// - [onRangePressed]: Callback for date range picker icon
  const _CustomRangeSelector({
    required this.range,
    required this.onStartDatePressed,
    required this.onEndDatePressed,
    required this.onRangePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 18),
            onPressed: onRangePressed,
            tooltip: 'Select date range',
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const VerticalDivider(width: 1),
          TextButton(
            onPressed: onStartDatePressed,
            child: Text(
              DateFormat('MMM d, y').format(range.start),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const Text('to', style: TextStyle(fontSize: 12)),
          TextButton(
            onPressed: onEndDatePressed,
            child: Text(
              DateFormat('MMM d, y').format(range.end),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
