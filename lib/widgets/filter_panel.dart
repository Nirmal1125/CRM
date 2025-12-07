// lib/widgets/filter_panel.dart
import 'package:flutter/material.dart';

/// Simple data-carrying model for filters. Extend fields as needed.
class FilterModel {
  DateTime? startDate;
  DateTime? endDate;
  String? quickRange;
  Map<String, bool> status = {
    'New Lead': true,
    'Follow Up': false,
    'Hot Lead': false,
    'Lost Lead': false,
  };
  String? company;
  int? scoreMin;
  int? scoreMax;
  Map<String, bool> tags = {
    'Logistics': true,
    'Management': false,
    'Marketing': false,
    'Finance': true,
    'Banking': false,
    'New Partner': false,
    'Priority Partner': false,
    'Business Partner': false,
    'Top management': false,
    'Contact Person': false,
  };

  @override
  String toString() {
    return 'start:$startDate end:$endDate range:$quickRange status:$status company:$company scoreMin:$scoreMin scoreMax:$scoreMax tags:$tags';
  }
}

/// Reusable FilterPanel widget. Provide onApply to receive the FilterModel.
class FilterPanel extends StatefulWidget {
  final void Function(FilterModel) onApply;
  final VoidCallback? onClear;

  const FilterPanel({Key? key, required this.onApply, this.onClear}) : super(key: key);

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  final FilterModel _filter = FilterModel();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _scoreMinController = TextEditingController();
  final TextEditingController _scoreMaxController = TextEditingController();

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _filter.startDate = picked;
        } else {
          _filter.endDate = picked;
        }
      });
    }
  }

  void _setQuickRange(String range) {
    final now = DateTime.now();
    setState(() {
      _filter.quickRange = range;
      if (range == 'This week') {
        final start = now.subtract(Duration(days: now.weekday - 1));
        _filter.startDate = DateTime(start.year, start.month, start.day);
        _filter.endDate = _filter.startDate!.add(const Duration(days: 6));
      } else if (range == 'This month') {
        _filter.startDate = DateTime(now.year, now.month, 1);
        _filter.endDate = DateTime(now.year, now.month + 1, 0);
      } else if (range == 'This year') {
        _filter.startDate = DateTime(now.year, 1, 1);
        _filter.endDate = DateTime(now.year, 12, 31);
      } else {
        _filter.startDate = null;
        _filter.endDate = null;
      }
    });
  }

  void _apply() {
    _filter.company = _companyController.text.isEmpty ? null : _companyController.text;
    _filter.scoreMin = int.tryParse(_scoreMinController.text);
    _filter.scoreMax = int.tryParse(_scoreMaxController.text);
    widget.onApply(_filter);
  }

  void _clear() {
    setState(() {
      _filter.startDate = null;
      _filter.endDate = null;
      _filter.quickRange = null;
      _filter.status.updateAll((key, value) => false);
      _companyController.clear();
      _scoreMinController.clear();
      _scoreMaxController.clear();
      _filter.tags.updateAll((key, value) => false);
    });
    if (widget.onClear != null) widget.onClear!();
  }

  @override
  void dispose() {
    _companyController.dispose();
    _scoreMinController.dispose();
    _scoreMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If used as an endDrawer, Drawer already adds SafeArea; keep layout flexible.
    final width = MediaQuery.of(context).size.width;
    final panelWidth = width > 900 ? width * 0.35 : width * 0.9;

    return Material(
      child: Container(
        width: panelWidth,
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('FILTER', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Date
            const Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(isStart: true),
                    child: Text(_filter.startDate == null ? 'Start Date' : _formatDate(_filter.startDate!)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(isStart: false),
                    child: Text(_filter.endDate == null ? 'End Date' : _formatDate(_filter.endDate!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: [
                _quickChip('This year'),
                _quickChip('This week'),
                _quickChip('This month'),
                _quickChip('+3'),
                _quickChip('+6'),
              ],
            ),

            const Divider(height: 24),

            // Status
            const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _filter.status.keys.map((k) {
                return FilterChip(
                  label: Text(k),
                  selected: _filter.status[k]!,
                  onSelected: (sel) => setState(() => _filter.status[k] = sel),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Company (text field - replace with Dropdown when hooking to data)
            const Text('Company', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _companyController,
              decoration: const InputDecoration(
                hintText: 'Please select',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),

            const SizedBox(height: 12),

            // Lead Score range
            const Text('Lead Score', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _scoreMinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Min',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('-', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _scoreMaxController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Max',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tags - scrollable area
            const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _filter.tags.keys.map((t) {
                    return FilterChip(
                      label: Text(t),
                      selected: _filter.tags[t]!,
                      onSelected: (v) => setState(() => _filter.tags[t] = v),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _clear,
                    child: const Text('Clear Filter'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _apply,
                    child: const Text('Apply Filter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip(String label) {
    final selected = _filter.quickRange == label;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _setQuickRange(label),
    );
  }

  static String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}
