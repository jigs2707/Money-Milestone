import os

files_to_fix = [
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
]

for file_path in files_to_fix:
    if not os.path.exists(file_path):
        continue

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    changed = False

    if 'AppColors.' in content:
        if 'app_colors_extension.dart' not in content:
            content = content.replace("import 'package:money_milestone/utils/colors.dart';", 
                "import 'package:money_milestone/utils/colors.dart';\nimport 'package:money_milestone/utils/app_colors_extension.dart';")
        content = content.replace('AppColors.', 'context.colors.')
        content = content.replace('Utils.gradiant()', 'Utils.gradiant(context)')
        changed = True

    if changed:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {file_path}")

