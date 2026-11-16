import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_milestone/cubits/dateFormatCubit.dart';
import 'package:money_milestone/utils/app_colors_extension.dart';
import 'package:money_milestone/utils/dateFormatService.dart';
import 'package:money_milestone/utils/dateFormats.dart';
import 'package:money_milestone/utils/utils.dart';

/// Date format picker. Only a handful of options, so it's a plain list with a
/// live preview of today's date rather than the searchable currency picker.
Future<void> showDateFormatPicker(BuildContext context) async {
  final cubit = context.read<DateFormatCubit>();
  await Utils.showPremiumSheet(
    context: context,
    child: BlocProvider.value(
      value: cubit,
      child: const _DateFormatPickerSheet(),
    ),
  );
}

class _DateFormatPickerSheet extends StatelessWidget {
  const _DateFormatPickerSheet();

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return BlocBuilder<DateFormatCubit, DateFormatState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date Format',
                style: TextStyle(
                  color: context.colors.blackColors,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Used for every date shown in the app.',
                style: TextStyle(
                  color: context.colors.lightGreyColor,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              ...allDateFormats.map((option) {
                final selected = option.pattern == state.format.pattern;
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    context.read<DateFormatCubit>().selectDateFormat(option);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: selected
                          ? context.colors.accentColor.withValues(alpha: 0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? context.colors.accentColor.withValues(alpha: 0.45)
                            : context.colors.lightGreyColor
                                .withValues(alpha: 0.20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                option.label,
                                style: TextStyle(
                                  color: context.colors.blackColors,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormatService.preview(
                                    option.pattern, today),
                                style: TextStyle(
                                  color: context.colors.lightGreyColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_circle_rounded,
                              size: 20, color: context.colors.accentColor),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
