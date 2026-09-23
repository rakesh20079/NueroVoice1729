import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class BenchmarkReportScreen extends StatefulWidget {
  const BenchmarkReportScreen({super.key});

  @override
  State<BenchmarkReportScreen> createState() => _BenchmarkReportScreenState();
}

class _BenchmarkReportScreenState extends State<BenchmarkReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceCard,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: "Back to Home",
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "V1 → V2 Research Benchmark",
              style: AppTypography.headlineMd.copyWith(fontSize: 17),
            ),
            Text(
              "1729 Labs · Model Evolution & Training Pipeline",
              style: AppTypography.labelSm.copyWith(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryContainer,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primaryContainer,
          indicatorWeight: 2.5,
          labelStyle: AppTypography.labelSmBold.copyWith(fontSize: 12),
          tabs: const [
            Tab(text: "Benchmarks"),
            Tab(text: "Training Process"),
            Tab(text: "Cross-Validation"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBenchmarksTab(),
          _buildTrainingProcessTab(),
          _buildCrossValidationTab(),
        ],
      ),
    );
  }

  // --- TAB 1: BENCHMARKS ---
  Widget _buildBenchmarksTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Executive Summary Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryContainer.withValues(alpha: 0.08),
                      AppColors.primaryLight.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.primaryContainer.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "1729 LABS REPORT",
                            style: AppTypography.labelSmBold.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Text(
                          "Clinical Leap: +21.2% Gain",
                          style: AppTypography.labelSmBold.copyWith(
                            color: AppColors.primaryContainer,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "From V1 Pilot to V2 Production",
                      style: AppTypography.headlineLg.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "V1 validated feasibility on a 37-subject pilot cohort. V2 scaled to a 574-subject clinical cohort with leak-free StratifiedGroupKFold validation, achieving 94.25% test accuracy, 0.9763 AUC-ROC, and robust mobile quantization.",
                      style: AppTypography.bodyMd,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // KPI Grid (V1 vs V2 Key Leaps)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 580;
                  final width = isWide ? (constraints.maxWidth - 24) / 3 : constraints.maxWidth;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildKpiCard(
                        width: width,
                        title: "Peak Test Accuracy",
                        v1Val: "76.47%",
                        v2Val: "94.25%",
                        diff: "+17.78%",
                        isPositive: true,
                      ),
                      _buildKpiCard(
                        width: width,
                        title: "Mean Cross-Val AUC",
                        v1Val: "0.827",
                        v2Val: "0.964",
                        diff: "+0.137",
                        isPositive: true,
                      ),
                      _buildKpiCard(
                        width: width,
                        title: "Subject Cohort",
                        v1Val: "37 Subjects",
                        v2Val: "574 Groups",
                        diff: "15.5x Scale",
                        isPositive: true,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 28),

              Text("Model Benchmark Matrix (V1 vs V2)", style: AppTypography.headlineMd),
              const SizedBox(height: 6),
              Text(
                "Direct performance comparison on identical feature geometries (8 selected acoustic & dysphonic biomarkers):",
                style: AppTypography.bodyMd,
              ),
              const SizedBox(height: 16),

              // Model Table
              _buildModelComparisonCard(
                modelTitle: "Classical NN (FP32)",
                tag: "Baseline Deep Neural Network",
                tagColor: AppColors.secondary,
                v1Metrics: {"Acc": "76.5%", "AUC": "0.778", "F1": "0.667", "Sens": "50.0%", "Spec": "100.0%", "Lat": "0.04 ms", "Size": "4.13 KB"},
                v2Metrics: {"Acc": "94.25%", "AUC": "0.976", "F1": "0.941", "Sens": "93.7%", "Spec": "94.8%", "Lat": "0.05 ms", "Size": "4.13 KB"},
              ),

              const SizedBox(height: 16),

              _buildModelComparisonCard(
                modelTitle: "Classical INT8 (Quantized)",
                tag: "On-Device Mobile Engine",
                tagColor: AppColors.statusGreen,
                v1Metrics: {"Acc": "76.5%", "AUC": "0.778", "F1": "0.667", "Sens": "50.0%", "Spec": "100.0%", "Lat": "0.20 ms", "Size": "5.32 KB"},
                v2Metrics: {"Acc": "94.25%", "AUC": "0.976", "F1": "0.941", "Sens": "92.8%", "Spec": "95.7%", "Lat": "0.21 ms", "Size": "5.32 KB"},
              ),

              const SizedBox(height: 16),

              _buildModelComparisonCard(
                modelTitle: "Hybrid Quantum FP32 (VQC)",
                tag: "PennyLane 8-Qubit Variational Circuit",
                tagColor: AppColors.primaryContainer,
                v1Metrics: {"Acc": "64.7%", "AUC": "0.611", "F1": "0.571", "Sens": "50.0%", "Spec": "77.8%", "Lat": "15.6 ms", "Size": "4.32 KB"},
                v2Metrics: {"Acc": "92.04%", "AUC": "0.969", "F1": "0.918", "Sens": "91.0%", "Spec": "93.0%", "Lat": "15.6 ms", "Size": "4.32 KB"},
              ),

              const SizedBox(height: 16),

              _buildModelComparisonCard(
                modelTitle: "Hybrid Quantum INT8 (Quantized)",
                tag: "Serverless Quantized Hybrid",
                tagColor: AppColors.primary,
                v1Metrics: {"Acc": "70.6%", "AUC": "0.625", "F1": "0.615", "Sens": "50.0%", "Spec": "88.9%", "Lat": "16.0 ms", "Size": "5.63 KB"},
                v2Metrics: {"Acc": "93.36%", "AUC": "0.966", "F1": "0.931", "Sens": "91.0%", "Spec": "95.7%", "Lat": "16.6 ms", "Size": "5.63 KB"},
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 2: TRAINING PROCESS ---
  Widget _buildTrainingProcessTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("V2 Clinical Training Pipeline", style: AppTypography.headlineLg),
              const SizedBox(height: 6),
              Text(
                "How raw acoustic vowel phonations are transformed into calibrated neurological risk scores:",
                style: AppTypography.bodyMd,
              ),
              const SizedBox(height: 24),

              _buildProcessStep(
                stepNum: "01",
                title: "Audio Standardization & Denoising",
                subtitle: "16,000 Hz Mono · Silence Trimming",
                description:
                    "Audio recordings from the device microphone are resampled to a standardized 16 kHz single-channel stream. Silence and background environmental noise are trimmed using librosa.effects.trim(top_db=25), isolating the sustained vowel phonation.",
                badge: "Librosa + SoundFile",
              ),

              const SizedBox(height: 16),

              _buildProcessStep(
                stepNum: "02",
                title: "38-Feature Acoustic & Dysphonia Extraction",
                subtitle: "Time, Frequency & Praat Biometrics",
                description:
                    "Extracts 13 MFCC means, 13 MFCC standard deviations, fundamental frequency F0 via YIN, Zero Crossing Rate, Spectral Centroid, and Spectral Rolloff. Uses Praat-Parselmouth to compute clinical dysphonia markers: Jitter (local, rap, ppq5), Shimmer (local, apq3, apq5), and Harmonic-to-Noise Ratio (HNR).",
                badge: "Praat Parselmouth",
              ),

              const SizedBox(height: 16),

              _buildProcessStep(
                stepNum: "03",
                title: "Feature Selection & Normalization",
                subtitle: "8 Top Ranked Features · StandardScaler",
                description:
                    "To prevent overfitting on small feature spaces, mutual-information and random-forest ranking selected the 8 most discriminative features:\n• mfcc_std_1, mfcc_mean_1, mfcc_std_3, mfcc_std_0\n• mfcc_std_10, mfcc_std_2, mfcc_std_11, f0_mean\nNormalized via Scikit-Learn StandardScaler fitted exclusively on training folds.",
                badge: "Scikit-Learn",
              ),

              const SizedBox(height: 16),

              _buildProcessStep(
                stepNum: "04",
                title: "Quantum Hilbert Space Mapping (VQC)",
                subtitle: "PennyLane 8-Qubit State Vector",
                description:
                    "The 8 normalized features are angle-embedded into an 8-qubit quantum circuit. Variational rotation gates (Rot) and strongly entangling CNOT gates create non-linear multi-qubit correlations inaccessible to standard perceptrons, measured via PauliZ expectation values.",
                badge: "PennyLane + PyTorch",
              ),

              const SizedBox(height: 16),

              _buildProcessStep(
                stepNum: "05",
                title: "INT8 Dynamic Quantization",
                subtitle: "Zero-Latency Mobile Edge Execution",
                description:
                    "PyTorch dynamic quantization reduces linear weights from 32-bit floats to 8-bit integers, yielding ~4x memory bandwidth savings and enabling real-time execution on mobile CPUs without sacrificing diagnostic sensitivity.",
                badge: "PyTorch Quantization",
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 3: CROSS-VALIDATION ---
  Widget _buildCrossValidationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("5-Fold Subject-Safe Cross-Validation", style: AppTypography.headlineLg),
              const SizedBox(height: 6),
              Text(
                "Ensuring clinical integrity: zero subject overlap between training and testing folds (StratifiedGroupKFold on 574 subject groups).",
                style: AppTypography.bodyMd,
              ),
              const SizedBox(height: 20),

              // Fold Breakdown Table
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle, width: 1),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: Text("Fold", style: AppTypography.labelSmBold)),
                          Expanded(flex: 3, child: Text("Classical Acc", style: AppTypography.labelSmBold)),
                          Expanded(flex: 3, child: Text("Classical AUC", style: AppTypography.labelSmBold)),
                          Expanded(flex: 3, child: Text("Quantum Acc", style: AppTypography.labelSmBold)),
                          Expanded(flex: 3, child: Text("Quantum AUC", style: AppTypography.labelSmBold)),
                        ],
                      ),
                    ),
                    _buildFoldRow("Fold 0", "91.2%", "0.951", "87.2%", "0.919"),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    _buildFoldRow("Fold 1", "91.6%", "0.975", "77.1%", "0.851"),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    _buildFoldRow("Fold 2", "88.5%", "0.958", "83.7%", "0.927"),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    _buildFoldRow("Fold 3", "91.6%", "0.952", "79.7%", "0.895"),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    _buildFoldRow("Fold 4", "95.1%", "0.984", "83.6%", "0.947"),
                    const Divider(height: 1, color: AppColors.borderSubtle),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.06),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              "MEAN",
                              style: AppTypography.labelSmBold.copyWith(
                                color: AppColors.primaryContainer,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "91.6% ±2.3%",
                              style: AppTypography.bodyMdMedium.copyWith(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "0.964 ±0.01",
                              style: AppTypography.bodyMdMedium.copyWith(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "82.3% ±3.9%",
                              style: AppTypography.bodyMdMedium.copyWith(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              "0.908 ±0.04",
                              style: AppTypography.bodyMdMedium.copyWith(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Cross-Val Evolution Callout
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 20, color: AppColors.statusGreen),
                        const SizedBox(width: 8),
                        Text("Why Subject-Safe Grouping Matters", style: AppTypography.headlineMd.copyWith(fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "In voice screening research, standard random cross-validation allows multiple audio samples from the same person to sit in both train and test splits, causing severe over-optimistic accuracy inflation. With StratifiedGroupKFold across all 574 subject groups, V2 guarantees zero subject leakage, ensuring real-world clinical reliability.",
                      style: AppTypography.bodyMd,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoldRow(String fold, String cAcc, String cAuc, String qAcc, String qAuc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(fold, style: AppTypography.bodyMdMedium)),
          Expanded(flex: 3, child: Text(cAcc, style: AppTypography.bodyMd)),
          Expanded(flex: 3, child: Text(cAuc, style: AppTypography.bodyMd)),
          Expanded(flex: 3, child: Text(qAcc, style: AppTypography.bodyMd)),
          Expanded(flex: 3, child: Text(qAuc, style: AppTypography.bodyMd)),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required double width,
    required String title,
    required String v1Val,
    required String v2Val,
    required String diff,
    required bool isPositive,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.labelSm),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                v2Val,
                style: AppTypography.headlineLg.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryContainer,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.statusGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  diff,
                  style: AppTypography.labelSmBold.copyWith(
                    color: AppColors.statusGreen,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "V1 Baseline: $v1Val",
            style: AppTypography.labelSm.copyWith(
              fontSize: 11,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelComparisonCard({
    required String modelTitle,
    required String tag,
    required Color tagColor,
    required Map<String, String> v1Metrics,
    required Map<String, String> v2Metrics,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  modelTitle,
                  style: AppTypography.headlineMd.copyWith(fontSize: 15),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: tagColor.withValues(alpha: 0.25), width: 0.8),
                ),
                child: Text(
                  tag,
                  style: AppTypography.labelSmBold.copyWith(
                    color: tagColor,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),

          // Two Columns: V1 vs V2
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("V1 Benchmark (Pilot)", style: AppTypography.labelSmBold.copyWith(fontSize: 11, color: AppColors.outline)),
                    const SizedBox(height: 6),
                    _buildMetricPair("Accuracy", v1Metrics["Acc"]!),
                    _buildMetricPair("ROC AUC", v1Metrics["AUC"]!),
                    _buildMetricPair("F1 Score", v1Metrics["F1"]!),
                    _buildMetricPair("Latency", v1Metrics["Lat"]!),
                  ],
                ),
              ),
              Container(width: 1, height: 95, color: AppColors.borderSubtle),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("V2 Clinical (Current)", style: AppTypography.labelSmBold.copyWith(fontSize: 11, color: AppColors.primaryContainer)),
                        const SizedBox(width: 4),
                        const Icon(Icons.check_circle_rounded, size: 12, color: AppColors.statusGreen),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _buildMetricPair("Accuracy", v2Metrics["Acc"]!, isHighlight: true),
                    _buildMetricPair("ROC AUC", v2Metrics["AUC"]!, isHighlight: true),
                    _buildMetricPair("F1 Score", v2Metrics["F1"]!, isHighlight: true),
                    _buildMetricPair("Latency", v2Metrics["Lat"]!),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPair(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.labelSm.copyWith(fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTypography.labelSm.copyWith(
              fontSize: 11.5,
              fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
              color: isHighlight ? AppColors.primaryContainer : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessStep({
    required String stepNum,
    required String title,
    required String subtitle,
    required String description,
    required String badge,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                stepNum,
                style: AppTypography.labelSmBold.copyWith(
                  color: AppColors.primaryContainer,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.headlineMd.copyWith(fontSize: 15.5),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: AppTypography.labelSmBold.copyWith(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.primaryContainer,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: AppTypography.bodyMd.copyWith(fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
