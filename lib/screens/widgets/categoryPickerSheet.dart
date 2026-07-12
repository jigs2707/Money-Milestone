import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/cubits/categoryCubit.dart';
import 'package:money_milestone/data/model/goalCategoryModel.dart';
import 'package:money_milestone/data/repository/categoryRepository.dart';
import 'package:money_milestone/data/repository/hiveRepository.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/utils/clarityService.dart';
import 'package:money_milestone/utils/goalCategories.dart';

/// Shows a bottom sheet for picking or creating a goal category.
/// Returns the selected [GoalCategoryModel] via Navigator.pop.
Future<GoalCategoryModel?> showCategoryPicker(
  BuildContext context, {
  String? currentCategoryId,
  List<GoalCategoryModel> customCategories = const [],
}) {
  return showModalBottomSheet<GoalCategoryModel>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => CategoryCubit(
        CategoryRepository(),
        HiveRepository.getUserId ?? '',
      ),
      child: _CategoryPickerSheet(
        currentCategoryId: currentCategoryId,
        initialCustomCategories: customCategories,
      ),
    ),
  );
}

class _CategoryPickerSheet extends StatefulWidget {
  const _CategoryPickerSheet({
    this.currentCategoryId,
    this.initialCustomCategories = const [],
  });

  final String? currentCategoryId;
  final List<GoalCategoryModel> initialCustomCategories;

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  bool _showCreate = false;

  // Create-form state
  final _nameController = TextEditingController();
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.colors.isDarkMode;
    final bg = isDark ? const Color(0xff0F1424) : Colors.white;

    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        final customs = state is CategoryLoaded
            ? state.customCategories
            : widget.initialCustomCategories;
        final all = GoalCategories.all(customs: customs);

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          builder: (_, controller) => Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                // ── Handle ─────────────────────────────────────────
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.lightGreyColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Title ───────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        _showCreate ? 'New Category' : 'Choose Category',
                        style: TextStyle(
                          color: context.colors.blackColors,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const Spacer(),
                      if (_showCreate)
                        GestureDetector(
                          onTap: () => setState(() => _showCreate = false),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: context.colors.lightGreyColor
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.close_rounded,
                                color: context.colors.lightGreyColor, size: 18),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),

                // ── Body ────────────────────────────────────────────
                Expanded(
                  child: _showCreate
                      ? _buildCreateForm(context)
                      : _buildCategoryList(context, all, controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Category list ────────────────────────────────────────────────────────────
  Widget _buildCategoryList(
    BuildContext context,
    List<GoalCategoryModel> categories,
    ScrollController controller,
  ) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: categories.length + 1, // +1 for the "create" button
      itemBuilder: (_, i) {
        if (i == categories.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GestureDetector(
              onTap: () => setState(() => _showCreate = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.colors.accentColor.withValues(alpha: 0.3),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded,
                        color: context.colors.accentColor, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Create Custom Category',
                      style: TextStyle(
                        color: context.colors.accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final cat = categories[i];
        final isSelected = cat.id == widget.currentCategoryId ||
            (widget.currentCategoryId == null && cat.id == 'other');

        return GestureDetector(
          onTap: () => Navigator.of(context).pop(cat),
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? cat.color.withValues(alpha: 0.1)
                  : context.colors.cardGlassColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? cat.color.withValues(alpha: 0.4)
                    : context.colors.cardBorderColor,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cat.color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(cat.icon, color: cat.color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    cat.name,
                    style: TextStyle(
                      color: context.colors.blackColors,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (cat.isCustom)
                  GestureDetector(
                    onTap: () =>
                        context.read<CategoryCubit>().deleteCategory(cat.id),
                    child: Icon(Icons.delete_outline_rounded,
                        size: 18,
                        color: context.colors.lightGreyColor
                            .withValues(alpha: 0.5)),
                  ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(Icons.check_circle_rounded,
                        color: cat.color, size: 20),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Create custom category form ───────────────────────────────────────────────
  Widget _buildCreateForm(BuildContext context) {
    final icons = GoalCategories.availableIcons;
    final colors = GoalCategories.availableColors;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name input
          _formLabel(context, Icons.label_outline_rounded, 'Category name'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            style: TextStyle(color: context.colors.blackColors),
            decoration: InputDecoration(
              hintText: 'e.g. Sports, Music...',
              hintStyle:
                  TextStyle(color: context.colors.lightGreyColor),
              filled: true,
              fillColor: context.colors.isDarkMode
                  ? const Color(0xff1C2135)
                  : const Color(0xffF4F5FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: context.colors.accentColor.withValues(alpha: 0.5)),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Icon picker
          _formLabel(context, Icons.emoji_emotions_outlined, 'Pick an icon'),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: icons.length,
            itemBuilder: (_, i) {
              final selected = _selectedIconIndex == i;
              final color = colors[_selectedColorIndex];
              return GestureDetector(
                onTap: () => setState(() => _selectedIconIndex = i),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? color.withValues(alpha: 0.15)
                        : context.colors.cardGlassColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? color.withValues(alpha: 0.5)
                          : context.colors.cardBorderColor,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Icon(icons[i],
                      size: 22,
                      color: selected
                          ? color
                          : context.colors.lightGreyColor),
                ),
              );
            },
          ),

          const SizedBox(height: 20),

          // Color picker
          _formLabel(context, Icons.palette_outlined, 'Pick a color'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(colors.length, (i) {
              final selected = _selectedColorIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = i),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors[i],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: colors[i].withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : [],
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 18)
                      : null,
                ),
              );
            }),
          ),

          const SizedBox(height: 28),

          // Preview + save
          _buildPreview(context, icons, colors),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _saveCustomCategory(context, icons, colors),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.accentColor,
                    context.colors.accentColor.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: context.colors.accentColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Save Category',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(
      BuildContext context, List<IconData> icons, List<Color> colors) {
    final icon = icons[_selectedIconIndex];
    final color = colors[_selectedColorIndex];
    final name = _nameController.text.trim().isEmpty
        ? 'Preview'
        : _nameController.text.trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Text(
            name,
            style: TextStyle(
              color: context.colors.blackColors,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  void _saveCustomCategory(
      BuildContext context, List<IconData> icons, List<Color> colors) {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final newCat = GoalCategoryModel(
      id: '', // Firestore generates the ID
      name: name,
      icon: icons[_selectedIconIndex],
      color: colors[_selectedColorIndex],
      isCustom: true,
    );

    ClarityService.logCategoryCreated(categoryName: name);
    context.read<CategoryCubit>().addCategory(newCat).then((_) {
      setState(() {
        _showCreate = false;
        _nameController.clear();
      });
    });
  }

  Widget _formLabel(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 15, color: context.colors.accentColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: context.colors.blackColors,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
