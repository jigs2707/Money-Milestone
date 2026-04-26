import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/data/repository/userRepository.dart';
import 'package:money_milestone/utils/currencies.dart';
import 'package:money_milestone/utils/currencyService.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class CurrencyState {
  final CurrencyData currency;
  final bool isLoading;

  const CurrencyState({required this.currency, this.isLoading = false});

  CurrencyState copyWith({CurrencyData? currency, bool? isLoading}) =>
      CurrencyState(
        currency: currency ?? this.currency,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class CurrencyCubit extends Cubit<CurrencyState> {
  final UserRepository _repo;

  CurrencyCubit(this._repo)
      : super(CurrencyState(currency: CurrencyService.instance.current));

  /// Call once after login — loads the saved currency from Firestore and
  /// updates [CurrencyService] so all `.currency()` calls immediately reflect it.
  Future<void> loadCurrency() async {
    final userId = HiveRepository.getUserId;
    if (userId == null || userId.isEmpty) return;

    emit(state.copyWith(isLoading: true));
    final code = await _repo.getCurrencyCode(userId: userId);
    final data = currencyByCode(code);
    CurrencyService.instance.update(data);
    emit(CurrencyState(currency: data));
  }

  /// Saves the selected currency to Firestore + updates [CurrencyService].
  Future<void> selectCurrency(CurrencyData data) async {
    CurrencyService.instance.update(data);
    emit(state.copyWith(currency: data));

    final userId = HiveRepository.getUserId;
    if (userId == null || userId.isEmpty) return;
    await _repo.saveCurrencyCode(userId: userId, code: data.code);
  }
}
