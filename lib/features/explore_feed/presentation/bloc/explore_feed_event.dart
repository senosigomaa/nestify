import 'package:equatable/equatable.dart';
import '../../domain/entities/property_entity.dart';

abstract class ExploreFeedEvent extends Equatable {
  const ExploreFeedEvent();

  @override
  List<Object?> get props => [];
}

class LoadExploreFeedEvent extends ExploreFeedEvent {
  final bool refresh;

  const LoadExploreFeedEvent({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class SwipeLeftEvent extends ExploreFeedEvent {
  final PropertyEntity property;

  const SwipeLeftEvent(this.property);

  @override
  List<Object?> get props => [property];
}

class SwipeRightEvent extends ExploreFeedEvent {
  final PropertyEntity property;

  const SwipeRightEvent(this.property);

  @override
  List<Object?> get props => [property];
}

class UndoLastSwipeEvent extends ExploreFeedEvent {
  const UndoLastSwipeEvent();
}

class ResetFeedDeckEvent extends ExploreFeedEvent {
  const ResetFeedDeckEvent();
}

class BookTourRequestedEvent extends ExploreFeedEvent {
  final PropertyEntity property;
  final DateTime tourDate;

  const BookTourRequestedEvent({
    required this.property,
    required this.tourDate,
  });

  @override
  List<Object?> get props => [property, tourDate];
}

class FilterNeighborhoodEvent extends ExploreFeedEvent {
  final String? neighborhood;

  const FilterNeighborhoodEvent(this.neighborhood);

  @override
  List<Object?> get props => [neighborhood];
}

class ToggleSavePropertyEvent extends ExploreFeedEvent {
  final PropertyEntity property;

  const ToggleSavePropertyEvent(this.property);

  @override
  List<Object?> get props => [property];
}

class AddNewPropertyEvent extends ExploreFeedEvent {
  final PropertyEntity property;

  const AddNewPropertyEvent(this.property);

  @override
  List<Object?> get props => [property];
}
