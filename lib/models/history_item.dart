class HistoryItem {
  final String id;
  final String dateTime;
  final String riskCategory;
  final double confidence;
  final String modelUsed;
  final double jitter;
  final double shimmer;
  final double? hnr;
  final String vocalStability;
  final String tremorIncidence;
  final String articulationRate;
  final String duration;
  final String rationale;
  final String? audioUrl;
  final String? audioFilename;

  const HistoryItem({
    required this.id,
    required this.dateTime,
    required this.riskCategory,
    required this.confidence,
    required this.modelUsed,
    required this.jitter,
    required this.shimmer,
    this.hnr,
    required this.vocalStability,
    required this.tremorIncidence,
    required this.articulationRate,
    required this.duration,
    required this.rationale,
    this.audioUrl,
    this.audioFilename,
  });
}
