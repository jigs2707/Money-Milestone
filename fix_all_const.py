import os
import re

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

    # match 'const WidgetName(' or 'const ClassName.namedConstructor('
    new_content = re.sub(r'const\s+([A-Z][A-Za-z0-9_]*\.?[a-zA-Z0-9_]*\()', r'\1', content)

    # Some specific ones that might have spaces like const BoxConstraints (
    new_content = re.sub(r'const\s+([A-Z][A-Za-z0-9_]*\s*\()', r'\1', new_content)

    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Removed const invocations in {file_path}")

