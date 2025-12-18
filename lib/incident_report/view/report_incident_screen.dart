import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:safe_zone/map/models/incident_model.dart';

/// Simplified category-based incident reporting screen
class ReportIncidentScreen extends StatefulWidget {
  const ReportIncidentScreen({
    required this.onSubmit,
    super.key,
  });

  final void Function(
    IncidentCategory category,
    String title,
    String description,
    bool notifyNearby,
  )
  onSubmit;

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  IncidentCategory? _selectedCategory;
  bool _notifyNearby = true;
  bool _isSubmitting = false;

  String _getTitleForCategory(IncidentCategory category) {
    return category.displayName;
  }

  String _getDescriptionForCategory(IncidentCategory category) {
    switch (category) {
      case IncidentCategory.suspicious:
        return 'Suspicious activity has been reported in this area';
      case IncidentCategory.lighting:
        return 'Poor lighting has been reported in this area';
      case IncidentCategory.vandalism:
        return 'Vandalism has been reported in this area';
      case IncidentCategory.harassment:
        return 'Harassment has been reported in this area';
      case IncidentCategory.roadHazard:
        return 'A road hazard has been reported in this area';
      case IncidentCategory.animalDanger:
        return 'A dangerous animal has been reported in this area';
      case IncidentCategory.medicalEmergency:
        return 'A medical emergency has been reported in this area';
      case IncidentCategory.naturalDisaster:
        return 'A natural disaster has been reported in this area';
      case IncidentCategory.powerOutage:
        return 'A power outage has been reported in this area';
      case IncidentCategory.waterIssue:
        return 'A water issue has been reported in this area';
      case IncidentCategory.noise:
        return 'Excessive noise has been reported in this area';
      case IncidentCategory.trespassing:
        return 'Trespassing has been reported in this area';
      case IncidentCategory.drugActivity:
        return 'Drug activity has been reported in this area';
      case IncidentCategory.weaponSighting:
        return 'A weapon has been sighted in this area';
      default:
        return 'A ${category.displayName.toLowerCase()} incident has been reported in this area';
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedCategory == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Simulate submission delay
    await Future<void>.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      widget.onSubmit(
        _selectedCategory!,
        _getTitleForCategory(_selectedCategory!),
        _getDescriptionForCategory(_selectedCategory!),
        _notifyNearby,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Report Incident',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Quick info banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your report helps keep the community safe',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Category selection
          Text(
            'Select Incident Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Category cards
          ...IncidentCategory.values.map((category) {
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? category.color.withValues(alpha: 0.1)
                        : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? category.color
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? category.color
                              : category.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          category.icon,
                          color: isSelected
                              ? Colors.white
                              : category.color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          category.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: isSelected
                                ? category.color
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle,
                          color: category.color,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 12),

          // Notify nearby toggle
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  LineIcons.bell,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notify Nearby Users',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Alert community members in this area',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _notifyNearby,
                  onChanged: (value) {
                    setState(() {
                      _notifyNearby = value;
                    });
                  },
                  activeThumbColor: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Submit button
          ElevatedButton(
            onPressed: _isSubmitting || _selectedCategory == null
                ? null
                : _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              disabledBackgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Submit Report',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
