import '../constants/api_constants.dart';
import '../models/consultation.dart';
import 'api_client.dart';

/// Consultations & VIP Concierge API Service matching API_DOCUMENTATION.md
class ConsultationService {
  final ApiClient _client;

  ConsultationService(this._client);

  /// Book Bespoke Haute Consultation
  Future<Consultation> bookConsultation({
    required String fullName,
    required String email,
    required String phone,
    String archPlacement = 'Top 8 Teeth',
    String preciousMetal = '18K Royal Yellow Gold',
    String diamondGrade = 'VVS1 Colorless Diamonds',
    String? notes,
    String? appointmentDate,
  }) async {
    final response = await _client.post(
      ApiConstants.consultations,
      data: {
        'fullName': fullName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'archPlacement': archPlacement,
        'preciousMetal': preciousMetal,
        'diamondGrade': diamondGrade,
        if (notes != null && notes.isNotEmpty) 'notes': notes.trim(),
        if (appointmentDate != null) 'appointmentDate': appointmentDate,
      },
    );

    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final conMap = data['consultation'] as Map<String, dynamic>? ?? data;
    return Consultation.fromJson(conMap);
  }

  /// List Consultations
  Future<List<Consultation>> getConsultations() async {
    try {
      final response = await _client.get(ApiConstants.consultations);
      final data = response.data['data'];
      List items = [];
      if (data is List) {
        items = data;
      } else if (data is Map && data['consultations'] is List) {
        items = data['consultations'] as List;
      }
      return items
          .map((c) => Consultation.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Get Consultation Details by ID
  Future<Consultation> getConsultationById(String id) async {
    final response = await _client.get(ApiConstants.consultationDetail(id));
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final conMap = data['consultation'] as Map<String, dynamic>? ?? data;
    return Consultation.fromJson(conMap);
  }
}
