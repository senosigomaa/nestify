import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/repositories/property_repository.dart';
import 'explore_feed_event.dart';
import 'explore_feed_state.dart';

/// ExploreFeedBloc handles swipe dynamics, undo stack, local bookmarking, and tour requests.
class ExploreFeedBloc extends Bloc<ExploreFeedEvent, ExploreFeedState> {
  final PropertyRepository repository;

  ExploreFeedBloc({required this.repository})
      : super(const ExploreFeedState()) {
    on<LoadExploreFeedEvent>(_onLoadExploreFeed);
    on<SwipeLeftEvent>(_onSwipeLeft);
    on<SwipeRightEvent>(_onSwipeRight);
    on<UndoLastSwipeEvent>(_onUndoLastSwipe);
    on<ResetFeedDeckEvent>(_onResetFeedDeck);
    on<BookTourRequestedEvent>(_onBookTourRequested);
    on<FilterNeighborhoodEvent>(_onFilterNeighborhood);
    on<ToggleSavePropertyEvent>(_onToggleSaveProperty);
    on<AddNewPropertyEvent>(_onAddNewProperty);
  }

  void _onAddNewProperty(
    AddNewPropertyEvent event,
    Emitter<ExploreFeedState> emit,
  ) {
    final updatedAll = [event.property, ...state.allProperties];
    final updatedDeck = [event.property, ...state.activeDeck];
    emit(state.copyWith(
      allProperties: updatedAll,
      activeDeck: updatedDeck,
    ));
  }

  Future<void> _onLoadExploreFeed(
    LoadExploreFeedEvent event,
    Emitter<ExploreFeedState> emit,
  ) async {
    emit(state.copyWith(status: ExploreStatus.loading));
    try {
      final properties = await repository.getProperties();
      final saved = await repository.getSavedProperties();

      emit(
        state.copyWith(
          status: ExploreStatus.loaded,
          allProperties: properties,
          activeDeck: properties,
          savedProperties: saved,
          swipedHistory: [],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ExploreStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSwipeLeft(
    SwipeLeftEvent event,
    Emitter<ExploreFeedState> emit,
  ) {
    final updatedDeck = state.activeDeck
        .where((p) => p.id != event.property.id)
        .toList(growable: true);
    final action = SwipedAction(property: event.property, isLiked: false);

    emit(
      state.copyWith(
        activeDeck: updatedDeck,
        swipedHistory: [...state.swipedHistory, action],
        lastActionProperty: event.property,
      ),
    );
  }

  Future<void> _onSwipeRight(
    SwipeRightEvent event,
    Emitter<ExploreFeedState> emit,
  ) async {
    final updatedDeck = state.activeDeck
        .where((p) => p.id != event.property.id)
        .toList(growable: true);
    final action = SwipedAction(property: event.property, isLiked: true);
    final updatedSaved = [...state.savedProperties, event.property];

    emit(
      state.copyWith(
        activeDeck: updatedDeck,
        savedProperties: updatedSaved,
        swipedHistory: [...state.swipedHistory, action],
        lastActionProperty: event.property,
      ),
    );

    try {
      await repository.saveProperty(event.property);
    } catch (_) {
      // Local write fallback handled silently
    }
  }

  Future<void> _onUndoLastSwipe(
    UndoLastSwipeEvent event,
    Emitter<ExploreFeedState> emit,
  ) async {
    if (state.swipedHistory.isEmpty) return;

    final history = List<SwipedAction>.from(state.swipedHistory);
    final lastAction = history.removeLast();

    final updatedDeck = [lastAction.property, ...state.activeDeck];
    List<dynamic> updatedSaved = List.from(state.savedProperties);

    if (lastAction.isLiked) {
      updatedSaved.removeWhere((p) => p.id == lastAction.property.id);
      try {
        await repository.removeSavedProperty(lastAction.property.id);
      } catch (_) {}
    }

    emit(
      state.copyWith(
        activeDeck: updatedDeck,
        savedProperties: List.from(updatedSaved),
        swipedHistory: history,
        lastActionProperty: lastAction.property,
      ),
    );
  }

  void _onResetFeedDeck(
    ResetFeedDeckEvent event,
    Emitter<ExploreFeedState> emit,
  ) {
    emit(
      state.copyWith(
        activeDeck: List.from(state.allProperties),
        swipedHistory: [],
      ),
    );
  }

  Future<void> _onBookTourRequested(
    BookTourRequestedEvent event,
    Emitter<ExploreFeedState> emit,
  ) async {
    emit(state.copyWith(bookingStatus: BookingStatus.submitting));
    try {
      final success = await repository.bookTour(
        event.property.id,
        event.tourDate,
      );
      if (success) {
        emit(
          state.copyWith(
            bookingStatus: BookingStatus.success,
            lastBookedDate: event.tourDate,
            lastActionProperty: event.property,
          ),
        );
      } else {
        emit(
          state.copyWith(
            bookingStatus: BookingStatus.failure,
            errorMessage: 'Unable to reserve tour slot.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          bookingStatus: BookingStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onFilterNeighborhood(
    FilterNeighborhoodEvent event,
    Emitter<ExploreFeedState> emit,
  ) {
    if (event.neighborhood == null || event.neighborhood!.isEmpty) {
      emit(
        state.copyWith(
          activeDeck: List.from(state.allProperties),
          clearSelectedNeighborhood: true,
        ),
      );
    } else {
      final filtered = state.allProperties
          .where((p) => p.neighborhood.contains(event.neighborhood!))
          .toList();
      emit(
        state.copyWith(
          activeDeck: filtered,
          selectedNeighborhood: event.neighborhood,
        ),
      );
    }
  }

  Future<void> _onToggleSaveProperty(
    ToggleSavePropertyEvent event,
    Emitter<ExploreFeedState> emit,
  ) async {
    final isAlreadySaved =
        state.savedProperties.any((p) => p.id == event.property.id);
    final updatedSaved = List<PropertyEntity>.from(state.savedProperties);

    if (isAlreadySaved) {
      updatedSaved.removeWhere((p) => p.id == event.property.id);
      emit(state.copyWith(savedProperties: updatedSaved));
      try {
        await repository.removeSavedProperty(event.property.id);
      } catch (_) {}
    } else {
      updatedSaved.add(event.property);
      emit(state.copyWith(savedProperties: updatedSaved));
      try {
        await repository.saveProperty(event.property);
      } catch (_) {}
    }
  }
}
