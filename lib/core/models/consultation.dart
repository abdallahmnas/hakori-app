/// Consultation Booking Model matching API_DOCUMENTATION.md
class Consultation {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String archPlacement;
  final String preciousMetal;
  final String diamondGrade;
  final String? notes;
  final String status;
  final String? appointmentDate;
  final String? createdAt;

  const Consultation({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.archPlacement,
    required this.preciousMetal,
    required this.diamondGrade,
    this.notes,
    this.status = 'Pending',
    this.appointmentDate,
    this.createdAt,
  });

  factory Consultation.fromJson(Map<String, dynamic> json) {
    return Consultation(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      archPlacement: json['archPlacement']?.toString() ?? 'Top 8 Teeth',
      preciousMetal: json['preciousMetal']?.toString() ?? '18K Royal Yellow Gold',
      diamondGrade: json['diamondGrade']?.toString() ?? 'VVS1 Colorless Diamonds',
      notes: json['notes']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
      appointmentDate: json['appointmentDate']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'archPlacement': archPlacement,
      'preciousMetal': preciousMetal,
      'diamondGrade': diamondGrade,
      if (notes != null) 'notes': notes,
      'status': status,
      if (appointmentDate != null) 'appointmentDate': appointmentDate,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
