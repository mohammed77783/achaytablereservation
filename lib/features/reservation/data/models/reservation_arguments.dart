import 'package:achaytablereservation/features/reservation/data/models/available_table.dart';
import 'package:achaytablereservation/features/reservation/data/models/reservation_models.dart';
import 'package:achaytablereservation/features/reservation/logic/class/SelectedTimeSlot.dart';

class ReservationConfirmationArguments {
  final int restaurantId;
  final RestaurantInfo? restaurantInfo;
  final DateTime? selectedDate;
  final String? selectedHijriDate;
  final String selectedDateDisplay;
  final SelectedTimeSlot? selectedTimeSlot;
  final int? hallId;
  final String? hallName;
  final int guestCount;
  final int tableCapacity;
  final double pricePerPerson;
  final double totalPrice;
  final int availableTablesCount;
  final List<AvailableTable>? availableTables;
  final int requiredTables;
  final int totalCapacity;

  const ReservationConfirmationArguments({
    required this.restaurantId,
    this.restaurantInfo,
    this.selectedDate,
    this.selectedHijriDate,
    required this.selectedDateDisplay,
    this.selectedTimeSlot,
    this.hallId,
    this.hallName,
    this.guestCount = 1,
    this.tableCapacity = 4,
    this.pricePerPerson = 0.0,
    this.totalPrice = 0.0,
    this.availableTablesCount = 0,
    this.availableTables,
    this.requiredTables = 1,
    this.totalCapacity = 0,
  });
}

/// Enum to track where payment was initiated from
enum PaymentSource {
  reservationConfirmation, // From new reservation flow
  bookingDetails, // From existing booking details
}

class PaymentArguments {
  final double totalPrice;
  final int bookingId;
  final String? paymentDeadline;
  final int? paymentWindowMinutes;
  final List<AssignedTable>? assignedTables;

  // Invoice Details
  final String restaurantName;
  final String dateDisplay;
  final String timeDisplay;
  final int guestCount;

  // Navigation tracking
  final PaymentSource source;

  const PaymentArguments({
    required this.totalPrice,
    required this.bookingId,
    this.paymentDeadline,
    this.paymentWindowMinutes,
    this.assignedTables,
    required this.restaurantName,
    required this.dateDisplay,
    required this.timeDisplay,
    required this.guestCount,
    this.source = PaymentSource.reservationConfirmation,
  });
}
