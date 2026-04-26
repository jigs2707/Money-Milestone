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

    # replace all 'const TextStyle' with 'TextStyle'
    new_content = content.replace('const TextStyle', 'TextStyle')
    new_content = new_content.replace('const Text', 'Text')
    new_content = new_content.replace('const Icon', 'Icon')
    new_content = new_content.replace('const BorderSide', 'BorderSide')
    new_content = new_content.replace('const CircularProgressIndicator', 'CircularProgressIndicator')

    if new_content != content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Removed const in {file_path}")

