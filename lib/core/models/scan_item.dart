class ScanItem {
  final String id;
  final String title;
  final String scanDate;
  final String verifiedBy;
  final double precisionScore;
  final bool isUpperArch;
  final bool isVerified;
  final String fileFormat;
  final String fileSize;

  const ScanItem({
    required this.id,
    required this.title,
    required this.scanDate,
    required this.verifiedBy,
    required this.precisionScore,
    required this.isUpperArch,
    this.isVerified = true,
    this.fileFormat = 'STL / OBJ 3D Mesh',
    this.fileSize = '42.8 MB',
  });
}
