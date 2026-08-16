import os
import cv2
import json
import numpy as np
import tensorflow as tf
import pyttsx3

keras = tf.keras

# =====================================================
# PATH CONFIGURATION
# =====================================================

BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

MODEL_PATH = os.path.join(BASE_DIR, "models", "best_model.h5")
LABELS_PATH = os.path.join(BASE_DIR, "models", "labels.json")

# =====================================================
# LOAD MODEL AND LABELS
# =====================================================

if not os.path.exists(MODEL_PATH):
    print("Error: best_model.h5 not found.")
    print("Please copy your best model into ai_system/models/best_model.h5")
    exit()

if not os.path.exists(LABELS_PATH):
    print("Error: labels.json not found.")
    print("Please make sure labels.json exists inside ai_system/models/")
    exit()

model = keras.models.load_model(MODEL_PATH)

with open(LABELS_PATH, "r") as f:
    class_names = json.load(f)

print("Model loaded successfully.")
print("Classes:", class_names)

# =====================================================
# GET MODEL INPUT SIZE AUTOMATICALLY
# =====================================================

input_shape = model.input_shape
IMG_HEIGHT = input_shape[1]
IMG_WIDTH = input_shape[2]

print(f"Model input size: {IMG_WIDTH}x{IMG_HEIGHT}")

# =====================================================
# TEXT TO SPEECH SETUP
# =====================================================

engine = pyttsx3.init()
engine.setProperty("rate", 150)
engine.setProperty("volume", 1.0)

def speak_text(text):
    if text.strip() != "":
        engine.say(text)
        engine.runAndWait()

# =====================================================
# SENTENCE BUILDER
# =====================================================

sentence = ""
last_prediction = ""
stable_count = 0
STABLE_THRESHOLD = 15
CONFIDENCE_THRESHOLD = 0.70

# =====================================================
# PREPROCESS FRAME
# =====================================================

def preprocess_frame(frame):
    image = cv2.resize(frame, (IMG_WIDTH, IMG_HEIGHT))
    image = image.astype("float32")

    # For CNN model with Rescaling layer, keep image as 0-255.
    # For MobileNetV2/EfficientNet model, preprocessing is already inside your model.
    image = np.expand_dims(image, axis=0)

    return image

# =====================================================
# CAMERA START
# =====================================================

cap = cv2.VideoCapture(0)

if not cap.isOpened():
    print("Error: Camera cannot be opened.")
    exit()

print("Camera started.")
print("Controls:")
print("Q = Quit")
print("A = Add detected sign")
print("SPACE = Add space")
print("D = Delete last character")
print("C = Clear sentence")
print("S = Speak sentence")

while True:
    ret, frame = cap.read()

    if not ret:
        print("Failed to capture frame.")
        break

    frame = cv2.flip(frame, 1)

    # Region of interest box
    h, w, _ = frame.shape
    x1, y1 = 100, 100
    x2, y2 = 400, 400

    roi = frame[y1:y2, x1:x2]

    input_image = preprocess_frame(roi)

    predictions = model.predict(input_image, verbose=0)
    predicted_index = np.argmax(predictions[0])
    confidence = predictions[0][predicted_index]
    predicted_label = class_names[predicted_index]

    if confidence >= CONFIDENCE_THRESHOLD:
        if predicted_label == last_prediction:
            stable_count += 1
        else:
            stable_count = 0
            last_prediction = predicted_label
    else:
        stable_count = 0
        last_prediction = ""

    # Draw ROI box
    cv2.rectangle(frame, (x1, y1), (x2, y2), (0, 255, 0), 2)

    # Display prediction
    cv2.putText(
        frame,
        f"Prediction: {predicted_label}",
        (50, 50),
        cv2.FONT_HERSHEY_SIMPLEX,
        1,
        (0, 255, 0),
        2
    )

    cv2.putText(
        frame,
        f"Confidence: {confidence * 100:.2f}%",
        (50, 90),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.8,
        (0, 255, 0),
        2
    )

    cv2.putText(
        frame,
        f"Sentence: {sentence}",
        (50, 460),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.9,
        (255, 255, 255),
        2
    )

    cv2.putText(
        frame,
        "A:Add | Space:Space | D:Delete | C:Clear | S:Speak | Q:Quit",
        (30, 520),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.6,
        (255, 255, 0),
        2
    )

    cv2.imshow("Deaf-Mute to Hearing - ASL Recognition", frame)

    key = cv2.waitKey(1) & 0xFF

    if key == ord("q"):
        break

    elif key == ord("a"):
        if confidence >= CONFIDENCE_THRESHOLD:
            sentence += predicted_label
            print("Added:", predicted_label)
            print("Sentence:", sentence)

    elif key == ord(" "):
        sentence += " "
        print("Space added.")
        print("Sentence:", sentence)

    elif key == ord("d"):
        sentence = sentence[:-1]
        print("Deleted last character.")
        print("Sentence:", sentence)

    elif key == ord("c"):
        sentence = ""
        print("Sentence cleared.")

    elif key == ord("s"):
        print("Speaking:", sentence)
        speak_text(sentence)

cap.release()
cv2.destroyAllWindows()