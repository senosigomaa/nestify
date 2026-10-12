import 'package:flutter_bloc/flutter_bloc.dart';
import 'co_living_event.dart';
import 'co_living_state.dart';

/// CoLivingBloc orchestrates real-time financial calculations for co-investment
/// and co-living splits with instant reactivity.
class CoLivingBloc extends Bloc<CoLivingEvent, CoLivingState> {
  CoLivingBloc() : super(const CoLivingState()) {
    on<InitializeCalculatorEvent>(_onInitialize);
    on<UpdateCoBuyersCountEvent>(_onUpdateCoBuyersCount);
    on<UpdateDownPaymentPercentageEvent>(_onUpdateDownPaymentPercentage);
    on<UpdateLoanTenureYearsEvent>(_onUpdateLoanTenureYears);
    on<UpdateInterestRateEvent>(_onUpdateInterestRate);
    on<ToggleSplitModeEvent>(_onToggleSplitMode);
  }

  void _onInitialize(
    InitializeCalculatorEvent event,
    Emitter<CoLivingState> emit,
  ) {
    emit(
      state.copyWith(
        propertyPrice: event.propertyPrice,
        splitMode: event.mode,
      ),
    );
  }

  void _onUpdateCoBuyersCount(
    UpdateCoBuyersCountEvent event,
    Emitter<CoLivingState> emit,
  ) {
    if (event.count < 1 || event.count > 6) return;
    emit(state.copyWith(coBuyersCount: event.count));
  }

  void _onUpdateDownPaymentPercentage(
    UpdateDownPaymentPercentageEvent event,
    Emitter<CoLivingState> emit,
  ) {
    emit(state.copyWith(downPaymentPercentage: event.percentage));
  }

  void _onUpdateLoanTenureYears(
    UpdateLoanTenureYearsEvent event,
    Emitter<CoLivingState> emit,
  ) {
    emit(state.copyWith(loanTenureYears: event.years));
  }

  void _onUpdateInterestRate(
    UpdateInterestRateEvent event,
    Emitter<CoLivingState> emit,
  ) {
    emit(state.copyWith(annualInterestRate: event.rate));
  }

  void _onToggleSplitMode(
    ToggleSplitModeEvent event,
    Emitter<CoLivingState> emit,
  ) {
    emit(state.copyWith(splitMode: event.mode));
  }
}
