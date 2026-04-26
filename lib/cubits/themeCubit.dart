import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';

abstract class ThemeState {}

class ThemeInitial extends ThemeState {}

class ThemeChanged extends ThemeState {
  final bool isDarkMode;
  ThemeChanged(this.isDarkMode);
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeInitial()) {
    _loadTheme();
  }

  bool get isDarkMode => HiveRepository.isDarkMode;

  void _loadTheme() {
    emit(ThemeChanged(isDarkMode));
  }

  void toggleTheme() {
    final newValue = !isDarkMode;
    HiveRepository.setDarkMode = newValue;
    emit(ThemeChanged(newValue));
  }
}
