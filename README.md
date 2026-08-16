# SignBuddy – Smart Two-Way Communication System

> **A Smart Two-Way Communication System between Deaf and Hearing People using Deep Learning and Natural Language Processing**

SignBuddy is an AI-powered mobile application designed to support communication between Deaf and hearing individuals.

The system provides two-way communication by recognizing American Sign Language (ASL) hand gestures and converting them into text and speech, while also allowing hearing users to communicate with Deaf users through text or speech that can be converted into ASL visual outputs.

This project was developed as a **Final Year Project (FYP)** for the **Bachelor of Computer Science (Artificial Intelligence)**.

---

## 📌 Table of Contents

- [Project Overview](#-project-overview)
- [Problem Statement](#-problem-statement)
- [Objectives](#-objectives)
- [Main Features](#-main-features)
- [System Workflow](#-system-workflow)
- [System Architecture](#-system-architecture)
- [AI Models](#-ai-models)
- [Dataset](#-dataset)
- [Technologies Used](#️-technologies-used)
- [Project Structure](#-project-structure)
- [Application Modules](#-application-modules)
- [Model Evaluation](#-model-evaluation)
- [Model Deployment](#-model-deployment)
- [Installation](#-installation)
- [How to Run](#-how-to-run)
- [Screenshots](#-screenshots)
- [Future Improvements](#-future-improvements)
- [Project Objectives Achievement](#-project-objectives-achievement)
- [Academic Information](#-academic-information)
- [Author](#-author)
- [License](#-license)

---

## 📌 Project Overview

Communication between Deaf and hearing individuals can be challenging when both parties do not understand sign language.

**SignBuddy** aims to reduce this communication barrier by combining Artificial Intelligence, Computer Vision, Deep Learning, Natural Language Processing, and Mobile Application Development.

The system supports two main communication directions:

### 1. Deaf → Hearing

The Deaf user performs an ASL hand gesture in front of the camera.

```text
ASL Hand Gesture
       ↓
Camera Input
       ↓
Image Preprocessing
       ↓
Deep Learning Model
       ↓
ASL Prediction
       ↓
Text Output
       ↓
Text-to-Speech
       ↓
Audio Output
