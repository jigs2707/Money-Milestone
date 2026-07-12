import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/data/model/goalCategoryModel.dart';
import 'package:money_milestone/data/repository/categoryRepository.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class CategoryState {}

class CategoryInitial extends CategoryState {}

class CategoryLoaded extends CategoryState {
  final List<GoalCategoryModel> customCategories;
  CategoryLoaded(this.customCategories);
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repo;
  final String _userId;
  StreamSubscription<List<GoalCategoryModel>>? _sub;

  CategoryCubit(this._repo, this._userId) : super(CategoryInitial()) {
    _sub = _repo.watchCategories(_userId).listen(
      (cats) => emit(CategoryLoaded(cats)),
      onError: (_) => emit(CategoryLoaded(const [])),
    );
  }

  Future<void> addCategory(GoalCategoryModel category) =>
      _repo.addCategory(_userId, category);

  Future<void> deleteCategory(String id) =>
      _repo.deleteCategory(_userId, id);

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
