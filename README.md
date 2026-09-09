# FoodFo

FoodFo is a Flutter-based Android app that uses machine learning to classify food images. Users can capture or upload photos, analyze them in real time, and instantly get food predictions.

[![Flutter Version](https://img.shields.io/badge/flutter-v3.47.2-blue?logo=flutter&logoColor=white)](https://github.com/flutter/flutter/blob/main/CHANGELOG.md#3472)
[![build](https://github.com/waffiqaziz/food_fo/actions/workflows/build.yml/badge.svg)](https://github.com/waffiqaziz/food_fo/actions/workflows/build.yml)

## Why the name FoodFo?

A short, catchy name from **Food** + **Info**. Easy to remember and clearly reflects the app's purpose.

## Features

- **Real-time Image Capture** — Take photos directly within the app.
- **Instant Predictions** — Get immediate food classification results.
- **Local & Cloud Models** — Choose between on-device and Firebase ML models.
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

This app uses the **Google AIY Vision Classifier Food V1** TFLite model for food recognition.

- **Model Source**: [Kaggle - Google AIY Vision Classifier Food V1](https://www.kaggle.com/models/google/aiy/tfLite/vision-classifier-food-v1)
- **Format**: TensorFlow Lite (.tflite)
- **Purpose**: Multi-class food image classification

### About Firebase Model Hosting

Firebase Model Hosting allows models to be updated without releasing a new app version. However, it is [deprecated and will shut down on **June 15, 2027**](https://firebase.google.com/support/releases#firebase-ml-deprecated-2026). New Firebase projects can no longer use Firebase ML.

*This project (`main` branch) will use Firebase Model Hosting until the shutdown date.*

## Getting Started

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Prerequisites

Before you begin, ensure you have the following installed:

- [Git](https://git-scm.com/)
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
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
