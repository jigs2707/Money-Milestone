# Money Milestone

## Overview

The Money Milestone is a Flutter application designed to help users manage and achieve their financial goals. The application utilizes Firebase Firestore for the database and Firebase Authentication for user login and signup.

## Features

- User account creation using Firebase Email Authentication.
- Goal creation with details such as goal name, amount, and completion date.
- Add Transaction for saved money toward each goal.
- Insights into daily, weekly, and monthly savings required to meet the goal by the targeted date.
- Withdrawal entry recording to track money utilization.
- Transaction history for each financial goal.
- Progress visualization:
  - Percentage of goal achieved.
  - Money saved.
  - Money remaining to complete the goal.
  - Remaining days to achieve the goal.

## Validations and Restrictions

- Email and password validation during user account creation.
- Empty field validations to ensure all required fields are filled.
- Goal completion date validation to prevent past dates.
- Money transaction validations:
    - Prevent withdraw money transaction if no money has been saved.
    - Prevent add money transaction if the saved money reaches the goal target.
- Edit goal validations:
    -  User cannot edit the goal target amount to be less than the saved money.

## Technologies Used

- Flutter for the mobile application.
- Firebase Firestore for the database.
- Firebase Authentication for user login and signup.

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Firebase](https://console.firebase.google.com)
- [Firebase CLI](https://firebase.google.com/docs/cli)

### Firebase Authentication Setup:

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Select your project or create a new one.
3. Navigate to "Authentication" from the left sidebar.
4. Go to the "Sign-in method" tab.
5. Enable the "Email/Password" provider.

### Firebase Firestore Setup:

1. In the Firebase Console, go to the "Firestore Database" from the left sidebar.
2. Click "Create Database."
3. Select a location for your database and click "Next"
4. Choose "Start in production mode" 
5. Click "Enable" to set up Firestore in production mode.

### Firestore Security Rules:

Update your Firestore security rules with the following:

```firebase
service cloud.firestore {
  match /databases/{database}/documents {
    match /{database}/{userId} {
      allow read, update, delete: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
    }
     match /{database}/{userId}/{document=**} {
      allow read, update, delete: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
    }
  }
}
```
### Firestore collections
- Create these three collections in your firebase firestore database to use the application 
  - users
  - goals
  - transactions

### Installation

1. Clone the repository.
2. Run `flutter pub get`.
3. Set up Firebase Firestore and Authentication.


### Firebase CLI

1. Register your project with Firebase using the Firebase CLI.
2. Register the Android and iOS applications with Firebase; it will add all the required files needed to communicate with Firebase into your code.

## Usage

To use the Money Milestone:

1. Create an account using Email.
2. Add financial goals, specifying the goal name, amount, and completion date.
3. Record entries for saved money and withdrawals.
4. View insights into required savings and transaction history.

### App Preview

[Watch the App Preview](https://drive.google.com/file/d/1SiqEqW9NPfPRESQVvqozzNFrAaltqLeu/view?usp=sharing)


## Acknowledgments

- Thanks to Flutter for providing an excellent framework.
- Thanks to Firebase for authentication and database support.

## Contact

For questions or support, please contact [mjignesh.g@gmail.com].
