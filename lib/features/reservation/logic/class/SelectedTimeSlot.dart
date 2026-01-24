import 'package:achaytablereservation/features/reservation/data/models/reservation_models.dart';

/// Selected time slot with hall information
class SelectedTimeSlot {
  final TimeSlot timeSlot;
  final Hall hall;
  const SelectedTimeSlot({required this.timeSlot, required this.hall});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SelectedTimeSlot &&
        other.timeSlot == timeSlot &&
        other.hall == hall;
  }

  @override
  int get hashCode => Object.hash(timeSlot, hall);
}

enum AvailabilityStatus {
  available, // Has available time slots (متاح)
  unavailable, // No available slots (غير متاح)
  unknown, // Not yet fetched
}
