# FoodFo

FoodFo is a Flutter-based Android app that uses machine learning to classify food images. Users can capture or upload photos, analyze them in real time, and instantly get food predictions.

[![Flutter Version](https://img.shields.io/badge/flutter-v3.47.2-blue?logo=flutter&logoColor=white)](https://github.com/flutter/flutter/blob/main/CHANGELOG.md#3472)
[![build](https://github.com/waffiqaziz/food_fo/actions/workflows/build.yml/badge.svg)](https://github.com/waffiqaziz/food_fo/actions/workflows/build.yml)

## Why the name FoodFo?

A short, catchy name from **Food** + **Info**. Easy to remember and clearly reflects the app's purpose.

## Features

- **Real-time Image Capture** — Take photos directly within the app.
- **Instant Predictions** — Get immediate food classification results.
- **Cloud Models** — GitHub-hosted models.
- **Detailed Food Information** — Get nutrition and food details using generative AI and MealDB.

## Demo

<table>
  <tr>
    <th>Image Classification</th>
    <th>Detected Not Food</th>
    <th>From Camera Source</th>
    <th>Real-Time Detection</th>
  </tr>
  <tr>
    <td><img src="https://media.giphy.com/media/lpegMftBFQkkiROtYR/giphy.gif" height="400"></td>
    <td><img src="https://i.postimg.cc/brKt8f3B/image.png" alt="not-food" height="400"></td>
    <td><a href="https://media.giphy.com/media/DKn5oEuONRfoQYcl4n/giphy.gif">From Camera Source</a></td>
    <td><a href="https://media.giphy.com/media/plDkMAFXzyWpSRuhvf/giphy.gif">Real-Time Detection</a>
  </tr>
</table>

## Resource

## TheMealDB API

We use TheMealDB API to get pictures, ingredients, and recipe. Endpoint:
[www.themealdb.com/api/json/v1/1/search.php?s=Arrabiata](www.themealdb.com/api/json/v1/1/search.php?s=Arrabiata)

### Model

This app uses the **Google AIY Vision Classifier Food V1** TFLite model for food recognition. Hosted on [GitHub](https://github.com/waffiqaziz/foodfo-models).

- **Model Source**: [Kaggle - Google AIY Vision Classifier Food V1](https://www.kaggle.com/models/google/aiy/tfLite/vision-classifier-food-v1)
- **Format**: TensorFlow Lite (.tflite)
- **Purpose**: Multi-class food image classification

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed on your machine:

- [Git](https://git-scm.com/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [VS Code](https://code.visualstudio.com/download) or
[Android Studio](https://developer.android.com/studio)
- [Gemini API Key](https://aistudio.google.com/) (required for ML generative AI)
- [Firebase CLI](https://firebase.google.com/docs/cli#setup_update_cli) - Used to setup your Firebase project
- Firebase Account - You'll need a Firebase project (we'll set this up in the next steps)

For general Flutter guidance, refer to the [Flutter documentation](https://docs.flutter.dev/).

---

## Installation Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/waffiqaziz/foodfo.git
cd food_fo
```

### Step 2: Remove Existing Firebase Configuration Files

Delete the following files as they will be replaced with your own Firebase project configuration:

```bash
android/app/google-services.json
firebase.json
lib/firebase_options.dart
```

### Step 3: Set Up Your Firebase Project

#### 3.1 Initialize Firebase for Flutter

Follow the official Firebase setup guide to create and connect your Firebase project: [Firebase Flutter Setup Guide](https://firebase.google.com/docs/flutter/setup?platform=android)

This will generate new configuration files including `google-services.json` and `firebase_options.dart`.

#### 3.2 Configure Firebase AI Logic

Enable and configure Firebase AI Logic for your project: [Firebase AI Logic Setup Guide](https://firebase.google.com/docs/ai-logic/get-started?platform=flutter&api=dev#set-up-firebase)
> [!Note]
> Just follow "Step 1: Set up a Firebase project and connect your app", the others already set-up

#### 3.4 Enable Firebase App Check

Since November 2, 2026, Firebase App Check enforcement will be required to use Firebase AI Logic [Learn more](https://firebase.google.com/docs/ai-logic/faq-and-troubleshooting?authuser=0#security-app-check).

1. Enable and register your apps to use [App Check](https://console.firebase.google.com/project/_/appcheck)
2. Configure Debug Tokens for local development: [Android Debug Provider Setup](https://firebase.google.com/docs/app-check/flutter/debug-provider#android)
3. Enforce App Check for Firebase AI Logic in your Firebase Console to ensure AI requests are only accepted from verified app instances.  

### Step 4: Install Dependencies and Run the Application

Connect your device or emulator, then run the following command in your project directory:

```bash
flutter pub get
flutter run
```

## Troubleshooting

If you encounter issues during setup:

- Verify your Flutter SDK version: `flutter --version`
- Ensure all Firebase configuration files are properly generated
- Check that your Firebase project has the necessary APIs enabled
- Review Firebase Console for any service-specific configuration requirements

## Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [firebase_ai Package](https://pub.dev/packages/firebase_ai)

---

## Need Help?

If you run into any issues, please check the project's issue tracker or create a new issue with details about your problem.
