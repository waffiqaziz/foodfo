# FoodFo

FoodFo is a Flutter-based food image classification app that uses machine learning to recognize various types of food from photos. Designed with a clean UI and optimized performance, FoodFo allows users to capture, real-time analyze, and instantly get predictions about what food appears in an image.


[![Flutter Version](https://img.shields.io/badge/flutter-v3.35.3-blue?logo=flutter&logoColor=white)](https://github.com/flutter/flutter/blob/main/CHANGELOG.md#3353)
[![build](https://github.com/waffiqaziz/food_fo/actions/workflows/build.yml/badge.svg)](https://github.com/waffiqaziz/food_fo/actions/workflows/build.yml)

## Why the name FoodFo?

A short, catchy name from **Food** + **Info**. Easy to remember and clearly reflects the app's purpose.

## Features

- **Real-time Image Capture** - Take photos directly within the app
- **Instant Predictions** - Get immediate results about food in images
- **Clean UI** - Intuitive and user-friendly interface
- **Android Compatible** - Works seamlessly on Android devices

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

This app uses the **Google AIY Vision Classifier Food V1** TFLite model for food recognition.

- **Model Source**: [Kaggle - Google AIY Vision Classifier Food V1](https://www.kaggle.com/models/google/aiy/tfLite/vision-classifier-food-v1)
- **Format**: TensorFlow Lite (.tflite)
- **Purpose**: Multi-class food image classification

### Alternative: Firebase Model Hosting

If you want to host your model on Firebase for dynamic updates and version management:

- **Setup Guide**: [Manage hosted models with Firebase](https://firebase.google.com/docs/ml/manage-hosted-models)
- **Flutter Package**: [firebase_ml_model_downloader](https://pub.dev/packages/firebase_ml_model_downloader)

Firebase hosting allows you to update models without releasing new app versions.

## Getting Started

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Prerequisites

Before you begin, ensure you have the following installed:

- [Git](https://git-scm.com/) (latest stable version)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (at least **v3.35.3**)
- [VS Code](https://code.visualstudio.com/download) or 
[Android Studio](https://developer.android.com/studio)
- [Gemini API Key](https://aistudio.google.com/) (required for ML generative AI)

### Step by step

1. Clone the repository

    ```bash
    git clone https://github.com/waffiqaziz/foodfo.git
    cd food_fo
    ```

2. Install dependencies

    ```bash
    flutter pub get
    ```

3. Configure API Key

    Create a `.env` file in the project root:

    ```env
    GEMINI_API_KEY={YOUR_API_KEY}
    ```

4. Generate API files

    ```bash
    dart run build_runner build -d
    ```

5. Run the app

   ```bash
   flutter run
   ```
