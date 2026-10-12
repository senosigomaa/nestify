import 'package:equatable/equatable.dart';
import '../../domain/entities/property_entity.dart';

enum ExploreStatus { initial, loading, loaded, error }

enum BookingStatus { none, submitting, success, failure }

class SwipedAction extends Equatable {
  final PropertyEntity property;
  final bool isLiked;

  const SwipedAction({required this.property, required this.isLiked});

  @override
  List<Object?> get props => [property, isLiked];
}

class ExploreFeedState extends Equatable {
  final ExploreStatus status;
  final List<PropertyEntity> allProperties;
  final List<PropertyEntity> activeDeck;
  final List<PropertyEntity> savedProperties;
  final List<SwipedAction> swipedHistory;
  final String? selectedNeighborhood;
  final BookingStatus bookingStatus;
  final DateTime? lastBookedDate;
  final String? errorMessage;
  final PropertyEntity? lastActionProperty;

  const ExploreFeedState({
    this.status = ExploreStatus.initial,
    this.allProperties = const [],
    this.activeDeck = const [],
    this.savedProperties = const [],
    this.swipedHistory = const [],
    this.selectedNeighborhood,
    this.bookingStatus = BookingStatus.none,
    this.lastBookedDate,
    this.errorMessage,
    this.lastActionProperty,
  });

  bool get canUndo => swipedHistory.isNotEmpty;
  bool get isDeckEmpty => activeDeck.isEmpty;
  PropertyEntity? get currentTopCard =>
      activeDeck.isNotEmpty ? activeDeck.first : null;

  ExploreFeedState copyWith({
    ExploreStatus? status,
    List<PropertyEntity>? allProperties,
    List<PropertyEntity>? activeDeck,
    List<PropertyEntity>? savedProperties,
    List<SwipedAction>? swipedHistory,
    String? selectedNeighborhood,
    BookingStatus? bookingStatus,
    DateTime? lastBookedDate,
    String? errorMessage,
    PropertyEntity? lastActionProperty,
    bool clearSelectedNeighborhood = false,
  }) {
    return ExploreFeedState(
      status: status ?? this.status,
      allProperties: allProperties ?? this.allProperties,
      activeDeck: activeDeck ?? this.activeDeck,
      savedProperties: savedProperties ?? this.savedProperties,
      swipedHistory: swipedHistory ?? this.swipedHistory,
      selectedNeighborhood: clearSelectedNeighborhood
          ? null
          : (selectedNeighborhood ?? this.selectedNeighborhood),
      bookingStatus: bookingStatus ?? this.bookingStatus,
      lastBookedDate: lastBookedDate ?? this.lastBookedDate,
      errorMessage: errorMessage ?? this.errorMessage,
      lastActionProperty: lastActionProperty ?? this.lastActionProperty,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allProperties,
        activeDeck,
        savedProperties,
        swipedHistory,
        selectedNeighborhood,
        bookingStatus,
        lastBookedDate,
        errorMessage,
        lastActionProperty,
      ];
}
