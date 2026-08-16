import os
import cv2
import json
import numpy as np
import tensorflow as tf
import mediapipe as mp
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
    print("Error: best_model.h5 not found in ai_system/models/")
    exit()

if not os.path.exists(LABELS_PATH):
    print("Error: labels.json not found in ai_system/models/")
    exit()

model = keras.models.load_model(MODEL_PATH)

with open(LABELS_PATH, "r") as f:
    class_names = json.load(f)

print("Model loaded successfully.")
print("Classes:", class_names)

# =====================================================
# GET MODEL INPUT SIZE
# =====================================================

input_shape = model.input_shape
IMG_HEIGHT = input_shape[1]
IMG_WIDTH = input_shape[2]

print(f"Model input size: {IMG_WIDTH}x{IMG_HEIGHT}")

# =====================================================
# MEDIAPIPE HAND SETUP
# =====================================================

mp_hands = mp.solutions.hands
mp_drawing = mp.solutions.drawing_utils
mp_styles = mp.solutions.drawing_styles

hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=1,
    min_detection_confidence=0.6,
    min_tracking_confidence=0.6
)

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
# PREPROCESS FOR CNN
# =====================================================

def preprocess_hand_image(hand_image):
    image = cv2.resize(hand_image, (IMG_WIDTH, IMG_HEIGHT))
    image = image.astype("float32")
    image = np.expand_dims(image, axis=0)
    return image


# =====================================================
# GET HAND BOUNDING BOX
# =====================================================

def get_hand_bbox(hand_landmarks, frame_width, frame_height, padding=40):
    x_coordinates = []
    y_coordinates = []

    for landmark in hand_landmarks.landmark:
        x_coordinates.append(int(landmark.x * frame_width))
        y_coordinates.append(int(landmark.y * frame_height))

    x_min = max(min(x_coordinates) - padding, 0)
    y_min = max(min(y_coordinates) - padding, 0)
    x_max = min(max(x_coordinates) + padding, frame_width)
    y_max = min(max(y_coordinates) + padding, frame_height)

    return x_min, y_min, x_max, y_max


# =====================================================
# SENTENCE BUILDER VARIABLES
# =====================================================

sentence = ""
current_prediction = ""
current_confidence = 0.0

CONFIDENCE_THRESHOLD = 0.70

# =====================================================
# CAMERA START
# =====================================================

cap = cv2.VideoCapture(0)

if not cap.isOpened():
    print("Error: Camera cannot be opened.")
    exit()

print("Camera started.")
print("Controls:")
print("A = Add current prediction")
print("SPACE = Add space")
print("D = Delete last character")
print("C = Clear sentence")
print("S = Speak sentence")
print("Q = Quit")

while True:
    ret, frame = cap.read()

    if not ret:
        print("Failed to capture frame.")
        break

    frame = cv2.flip(frame, 1)
    frame_height, frame_width, _ = frame.shape

    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = hands.process(rgb_frame)

    current_prediction = "No Hand"
    current_confidence = 0.0

    if results.multi_hand_landmarks:
        for hand_landmarks in results.multi_hand_landmarks:
            # Draw landmarks on camera frame
            mp_drawing.draw_landmarks(
                frame,
                hand_landmarks,
                mp_hands.HAND_CONNECTIONS,
                mp_styles.get_default_hand_landmarks_style(),
                mp_styles.get_default_hand_connections_style()
            )

            # Get hand bounding box
            x_min, y_min, x_max, y_max = get_hand_bbox(
                hand_landmarks,
                frame_width,
                frame_height
            )

            # Draw bounding box
            cv2.rectangle(
                frame,
                (x_min, y_min),
                (x_max, y_max),
                (255, 0, 255),
                2
            )

            hand_crop = frame[y_min:y_max, x_min:x_max]

            if hand_crop.size != 0:
                input_image = preprocess_hand_image(hand_crop)

                predictions = model.predict(input_image, verbose=0)
                predicted_index = np.argmax(predictions[0])
                confidence = predictions[0][predicted_index]
                predicted_label = class_names[predicted_index]

                current_prediction = predicted_label
                current_confidence = confidence

    # =====================================================
    # DISPLAY TEXT
    # =====================================================

    cv2.putText(
        frame,
        f"Prediction: {current_prediction}",
        (30, 40),
        cv2.FONT_HERSHEY_SIMPLEX,
        1,
        (0, 255, 0),
        2
    )

    cv2.putText(
        frame,
        f"Confidence: {current_confidence * 100:.2f}%",
        (30, 80),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.8,
        (0, 255, 0),
        2
    )

    cv2.putText(
        frame,
        f"Sentence: {sentence}",
        (30, 440),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.9,
        (255, 255, 255),
        2
    )

    cv2.putText(
        frame,
        "A:Add | Space:Space | D:Delete | C:Clear | S:Speak | Q:Quit",
        (30, 480),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.6,
        (255, 255, 0),
        2
    )

    cv2.imshow("CNN + MediaPipe ASL Recognition", frame)

    key = cv2.waitKey(1) & 0xFF

    if key == ord("q"):
        break

    elif key == ord("a"):
        if current_prediction != "No Hand" and current_confidence >= CONFIDENCE_THRESHOLD:
            sentence += current_prediction
            print("Added:", current_prediction)
            print("Sentence:", sentence)
        else:
            print("Prediction confidence too low or no hand detected.")

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
hands.close()