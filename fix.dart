import 'dart:io';

void main() async {
  final files = [
    'lib/screens/widgets/addGoalDialog.dart',
    'lib/screens/widgets/addOrWithdrawMonetDialogWidget.dart',
    'lib/screens/widgets/customTextFormfield.dart',
    'lib/screens/widgets/customRoundedButton.dart',
    'lib/screens/widgets/customCircularProgressIndicator.dart',
    'lib/screens/widgets/messageContainer.dart',
    'lib/screens/widgets/backgroundWidget.dart',
    'lib/screens/widgets/customerShimmerWidget.dart',
    'lib/screens/ui/logInScreen.dart',
    'lib/screens/ui/signUpScreen.dart',
    'lib/screens/ui/splashScreen.dart',
    'lib/screens/ui/homeScreen.dart',
    'lib/screens/ui/goalDetailsScreen.dart',
  ];

  for (var filePath in files) {
    final file = File(filePath);
    if (!await file.exists()) continue;

    String content = await file.readAsString();
    bool changed = false;

    if (content.contains('AppColors.')) {
      if (!content.contains('app_colors_extension.dart')) {
         content = content.replaceFirst("import 'package:money_milestone/utils/colors.dart';", 
            "import 'package:money_milestone/utils/colors.dart';\nimport 'package:money_milestone/utils/app_colors_extension.dart';");
      }
      content = content.replaceAll('AppColors.', 'context.colors.');
      
      // Fix gradiant() -> gradiant(context)
      content = content.replaceAll('Utils.gradiant()', 'Utils.gradiant(context)');

      changed = true;
    }

    if (changed) {
      await file.writeAsString(content);
      print('Updated \$filePath');
    }
  }
}
