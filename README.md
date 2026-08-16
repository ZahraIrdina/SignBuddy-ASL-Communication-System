# SignBuddy – Smart Two-Way Communication System

SignBuddy is an AI-powered mobile application developed as my Final Year Project (FYP) to support two-way communication between Deaf and hearing individuals.

The system uses **Deep Learning, Computer Vision, Natural Language Processing (NLP), and Speech Technologies** to translate between sign language and spoken/text communication.

## 🎯 Project Overview

SignBuddy supports two main communication directions:

### Deaf → Hearing
- Uses the camera to capture ASL hand gestures
- Recognizes ASL alphabet and numbers using a Deep Learning model
- Converts recognized gestures into text
- Converts text into speech using Text-to-Speech

### Hearing → Deaf
- Accepts text or speech input
- Processes the input using NLP
- Provides corresponding ASL visual output
- Supports sign language videos and alphabet representations

## 🤖 AI Model

The project explores several Deep Learning approaches:

- CNN
- MobileNetV2
- EfficientNetB0

The selected model is converted to **TensorFlow Lite (TFLite)** for integration into the mobile application.

The ASL recognition model supports **36 classes**:

- A–Z
- 0–9

## 🛠️ Technologies

- Python
- TensorFlow / Keras
- TensorFlow Lite
- OpenCV
- MediaPipe
- Natural Language Processing (NLP)
- Flutter
- Dart
- Speech-to-Text
- Text-to-Speech

## 📱 Application

The mobile application includes:

- ASL Recognition
- Deaf-to-Hearing Communication
- Hearing-to-Deaf Communication
- Sign Video Output
- Alphabet Output
- Speech-to-Text
- Text-to-Speech

## 📂 Project Structure

```text
SignBuddy/
├── ai_system/
│   ├── training/
│   ├── evaluation/
│   └── realtime_testing/
│
├── mobile_app/
│   ├── lib/
│   └── assets/
│
├── models/
│   ├── asl_model.tflite
│   └── labels.txt
│
├── docs/
│   └── screenshots/
│
└── README.md
