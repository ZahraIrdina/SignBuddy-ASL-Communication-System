import os
import shutil
import tensorflow as tf
from tensorflow.python.framework.convert_to_constants import convert_variables_to_constants_v2

keras = tf.keras

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

MODEL_PATH_KERAS = os.path.join(BASE_DIR, "models", "best_model.keras")
MODEL_PATH_H5 = os.path.join(BASE_DIR, "models", "best_model.h5")

EXPORT_DIR = os.path.join(BASE_DIR, "export")
os.makedirs(EXPORT_DIR, exist_ok=True)

TFLITE_MODEL_PATH = os.path.join(EXPORT_DIR, "asl_model.tflite")

LABELS_SOURCE = os.path.join(BASE_DIR, "models", "labels.txt")
LABELS_DESTINATION = os.path.join(EXPORT_DIR, "labels.txt")

# =====================================================
# LOAD MODEL
# =====================================================

if os.path.exists(MODEL_PATH_KERAS):
    MODEL_PATH = MODEL_PATH_KERAS
elif os.path.exists(MODEL_PATH_H5):
    MODEL_PATH = MODEL_PATH_H5
else:
    print("ERROR: best_model.keras or best_model.h5 not found.")
    exit()

print("Loading model:", MODEL_PATH)

model = keras.models.load_model(MODEL_PATH, compile=False)

print("Model loaded successfully.")
print("Input shape:", model.input_shape)
print("Output shape:", model.output_shape)

# =====================================================
# FREEZE MODEL
# =====================================================

print("Freezing model...")

input_shape = model.input_shape

if input_shape[1] is None or input_shape[2] is None:
    input_height = 64
    input_width = 64
else:
    input_height = input_shape[1]
    input_width = input_shape[2]

full_model = tf.function(
    lambda x: model(x, training=False)
)

concrete_func = full_model.get_concrete_function(
    tf.TensorSpec(
        shape=[1, input_height, input_width, 3],
        dtype=tf.float32
    )
)

frozen_func = convert_variables_to_constants_v2(concrete_func)

print("Model frozen successfully.")

# =====================================================
# CONVERT TO TFLITE
# =====================================================

print("Converting frozen model to TFLite...")

converter = tf.lite.TFLiteConverter.from_concrete_functions([frozen_func])

converter.optimizations = []

tflite_model = converter.convert()

with open(TFLITE_MODEL_PATH, "wb") as f:
    f.write(tflite_model)

print("TFLite model saved successfully:")
print(TFLITE_MODEL_PATH)

# =====================================================
# COPY LABELS
# =====================================================

if os.path.exists(LABELS_SOURCE):
    shutil.copy(LABELS_SOURCE, LABELS_DESTINATION)
    print("labels.txt copied successfully.")
else:
    print("WARNING: labels.txt not found.")

print("\n===================================")
print("TFLITE CONVERSION COMPLETED")
print("===================================")
print("Generated:")
print("1. export/asl_model.tflite")
print("2. export/labels.txt")