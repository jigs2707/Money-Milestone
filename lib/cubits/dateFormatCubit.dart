import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/data/repository/userRepository.dart';
import 'package:money_milestone/utils/dateFormatService.dart';
import 'package:money_milestone/utils/dateFormats.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class DateFormatState {
  final DateFormatOption format;
  final bool isLoading;

  const DateFormatState({required this.format, this.isLoading = false});

  DateFormatState copyWith({DateFormatOption? format, bool? isLoading}) =>
      DateFormatState(
        format: format ?? this.format,
        isLoading: isLoading ?? this.isLoading,
      );
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class DateFormatCubit extends Cubit<DateFormatState> {
  final UserRepository _repo;

  DateFormatCubit(this._repo)
      : super(DateFormatState(format: DateFormatService.instance.current));

  /// Call once after login — loads the saved format and updates
  /// [DateFormatService] so every date on screen reflects it.
  Future<void> loadDateFormat() async {
    final userId = HiveRepository.getUserId;
    if (userId == null || userId.isEmpty) return;

    emit(state.copyWith(isLoading: true));
    final pattern = await _repo.getDateFormat(userId: userId);
    final option = dateFormatByPattern(pattern);
    DateFormatService.instance.update(option);
    emit(DateFormatState(format: option));
  }

  /// Persists the selection and updates [DateFormatService].
  Future<void> selectDateFormat(DateFormatOption option) async {
    DateFormatService.instance.update(option);
    emit(state.copyWith(format: option));

    final userId = HiveRepository.getUserId;
    if (userId == null || userId.isEmpty) return;
    await _repo.saveDateFormat(userId: userId, pattern: option.pattern);
  }
}
