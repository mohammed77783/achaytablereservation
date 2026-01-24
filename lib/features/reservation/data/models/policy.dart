/// Policy model representing a restaurant policy
import 'package:achaytablereservation/core/errors/exceptions.dart';

class Policy {
  final int policyId;
  final String policyText;
  final int displayOrder;
  Policy({
    required this.policyId,
    required this.policyText,
    required this.displayOrder,
  });

  /// Creates a Policy instance from JSON
  factory Policy.fromJson(Map<String, dynamic> json) {
    try {
      return Policy(
        policyId: json['policyId'] as int,
        policyText: json['policyText'] as String,
        displayOrder: json['displayOrder'] as int,
      );
    } catch (e) {
      throw ParsingException(
        'Failed to parse Policy from JSON: ${e.toString()}. JSON: $json',
      );
    }
  }

  /// Converts the Policy instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'policyId': policyId,
      'policyText': policyText,
      'displayOrder': displayOrder,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Policy &&
        other.policyId == policyId &&
        other.policyText == policyText &&
        other.displayOrder == displayOrder;
  }

  @override
  int get hashCode {
    return Object.hash(policyId, policyText, displayOrder);
  }

  @override
  String toString() {
    return 'Policy(policyId: $policyId, policyText: $policyText, displayOrder: $displayOrder)';
  }
}
