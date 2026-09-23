import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/history_item.dart';
import '../models/screening_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class HistoryScreen extends StatefulWidget {
  final ValueChanged<HistoryItem> onSelectHistoryItem;
  final VoidCallback onStartNewScreening;

  const HistoryScreen({
    super.key,
    required this.onSelectHistoryItem,
    required this.onStartNewScreening,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = "All";
  bool _isSelectionMode = false;
  final Set<String> _selectedIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ScreeningSessionProvider>().loadHistoryFromBackend();
    });
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _confirmDeleteSelected(BuildContext context) {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Select at least one screening assessment to delete."),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final int count = _selectedIds.length;
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        title: Text(
          "Delete Selected",
          style: AppTypography.headlineMd.copyWith(fontSize: 18),
        ),
        content: Text(
          "Are you sure you want to delete $count assessment(s)? This action cannot be undone.",
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(
              "Cancel",
              style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ScreeningSessionProvider>().deleteMultipleHistoryRecords(_selectedIds);
              setState(() {
                _selectedIds.clear();
                _isSelectionMode = false;
              });
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("$count assessment(s) deleted"),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ScreeningSessionProvider>();
    final allRecords = session.historyRecords;

    final filteredRecords = allRecords.where((item) {
      if (_selectedFilter == "All") return true;
      if (_selectedFilter == "Low Risk") {
        return item.riskCategory.toLowerCase().contains("low");
      }
      if (_selectedFilter == "Moderate") {
        return item.riskCategory.toLowerCase().contains("moderate");
      }
      return true;
    }).toList();

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Top-Right Delete Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Screening History", style: AppTypography.headlineLg),
                        const SizedBox(height: 2),
                        Text(
                          "Longitudinal acoustic records & telemetry.",
                          style: AppTypography.bodyMd,
                        ),
                      ],
                    ),
                  ),

                  // Top-Right Actions
                  if (allRecords.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isSelectionMode)
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isSelectionMode = true;
                              });
                            },
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: AppColors.onSurfaceVariant,
                            tooltip: "Select to delete",
                          )
                        else ...[
                          TextButton(
                            onPressed: () {
                              setState(() {
                                if (_selectedIds.length == filteredRecords.length) {
                                  _selectedIds.clear();
                                } else {
                                  _selectedIds.addAll(filteredRecords.map((r) => r.id));
                                }
                              });
                            },
                            child: Text(
                              _selectedIds.length == filteredRecords.length
                                  ? "Deselect All"
                                  : "Select All",
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton.icon(
                            onPressed: _selectedIds.isEmpty
                                ? null
                                : () => _confirmDeleteSelected(context),
                            icon: const Icon(Icons.delete_forever_rounded, size: 16),
                            label: Text("Delete (${_selectedIds.length})"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.statusRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isSelectionMode = false;
                                _selectedIds.clear();
                              });
                            },
                            icon: const Icon(Icons.close_rounded, size: 20),
                            color: AppColors.onSurfaceVariant,
                            tooltip: "Cancel Selection",
                          ),
                        ],
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Overview Metric Bento
              LayoutBuilder(
                builder: (context, constraints) {
                  final double tileWidth = (constraints.maxWidth - 12) / 2;

                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildMetricTile(
                        width: tileWidth,
                        label: "TOTAL ASSESSMENTS",
                        value: "${allRecords.length}",
                        subtext: "Complete sessions",
                      ),
                      _buildMetricTile(
                        width: tileWidth,
                        label: "AVG CONFIDENCE",
                        value: allRecords.isEmpty
                            ? "--"
                            : "${session.avgConfidence.toStringAsFixed(1)}%",
                        subtext: "Quantum + Ensemble",
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // Filter Chips
              if (allRecords.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildFilterChip("All", count: allRecords.length),
                    _buildFilterChip(
                      "Low Risk",
                      count: allRecords.where((r) => r.riskCategory.contains("Low")).length,
                    ),
                    _buildFilterChip(
                      "Moderate",
                      count: allRecords.where((r) => r.riskCategory.contains("Moderate")).length,
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // List of Assessment Cards
              if (allRecords.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle, width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history_toggle_off_rounded,
                          size: 28,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No screening history yet",
                        style: AppTypography.headlineMd.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Complete a voice screening to record your acoustic biomarkers and track clinical trends here.",
                        style: AppTypography.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: widget.onStartNewScreening,
                        icon: const Icon(Icons.mic, size: 18),
                        label: const Text("Start First Screening"),
                      ),
                    ],
                  ),
                )
              else if (filteredRecords.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      "No records match '$_selectedFilter'.",
                      style: AppTypography.bodyMd,
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredRecords.length,
                  separatorBuilder: (context, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final record = filteredRecords[index];
                    return _buildRecordCard(record, session);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required double width,
    required String label,
    required String value,
    required String subtext,
    Color? valueColor,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.headlineMd.copyWith(
              fontSize: 18,
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: AppTypography.labelSm.copyWith(
              fontSize: 11,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {required int count}) {
    final bool isSelected = _selectedFilter == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer.withValues(alpha: 0.12)
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryContainer.withValues(alpha: 0.4)
                : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        child: Text(
          "$label ($count)",
          style: AppTypography.labelSmBold.copyWith(
            fontSize: 11.5,
            color: isSelected ? AppColors.primaryContainer : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(HistoryItem record, ScreeningSessionProvider session) {
    final bool isLowRisk = record.riskCategory.toLowerCase().contains("low");
    final Color statusColor = isLowRisk ? AppColors.statusGreen : AppColors.statusAmber;
    final Color statusBg = isLowRisk
        ? AppColors.statusGreenLight.withValues(alpha: 0.8)
        : AppColors.statusAmberLight.withValues(alpha: 0.8);

    final bool isSelected = _selectedIds.contains(record.id);
    final bool isPlayingThis = session.isPlayingAudio && session.currentlyPlayingItemId == record.id;

    return InkWell(
      onTap: () {
        if (_isSelectionMode) {
          _toggleSelection(record.id);
        } else {
          widget.onSelectHistoryItem(record);
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer.withValues(alpha: 0.05)
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryContainer : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top card header: Checkbox (if in selection mode), Session ID, Date, Status badge
            Row(
              children: [
                if (_isSelectionMode) ...[
                  Checkbox(
                    value: isSelected,
                    activeColor: AppColors.primaryContainer,
                    onChanged: (_) => _toggleSelection(record.id),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        "#${record.id}",
                        style: AppTypography.labelSmBold.copyWith(
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          "· ${record.dateTime}",
                          style: AppTypography.labelSm.copyWith(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    record.riskCategory,
                    style: AppTypography.labelSmBold.copyWith(
                      color: statusColor,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Telemetry Wrap
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildTelemetryField("Confidence", "${record.confidence}%"),
                _buildTelemetryField("Jitter", "${record.jitter}%"),
                _buildTelemetryField("Shimmer", "${record.shimmer}%"),
                _buildTelemetryField("Model", record.modelUsed),
                _buildTelemetryField("Stability", record.vocalStability),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: 10),

            // Bottom action row: Audio Rehear Button + Detailed Explanation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Audio Rehear Pill Button
                InkWell(
                  onTap: () {
                    session.togglePlayHistoryItem(record);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isPlayingThis
                          ? AppColors.primaryContainer.withValues(alpha: 0.18)
                          : AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isPlayingThis
                            ? AppColors.primaryContainer
                            : AppColors.borderSubtle,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPlayingThis
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          size: 17,
                          color: AppColors.primaryContainer,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isPlayingThis ? "Playing (${record.duration})" : "Rehear Voice (${record.duration})",
                          style: AppTypography.labelSmBold.copyWith(
                            fontSize: 11,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isSelectionMode
                          ? (isSelected ? "Selected" : "Select")
                          : "Detailed Explanation",
                      style: AppTypography.labelSmBold.copyWith(
                        color: AppColors.primaryContainer,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isSelectionMode
                          ? (isSelected
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded)
                          : Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: AppColors.primaryContainer,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.labelSm.copyWith(fontSize: 10.5),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: AppTypography.bodyMdMedium.copyWith(fontSize: 12.5),
        ),
      ],
    );
  }
}
