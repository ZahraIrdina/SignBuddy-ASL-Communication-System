import os
import json
import matplotlib.pyplot as plt
import tensorflow as tf

keras = tf.keras
layers = keras.layers

# =====================================================
# PATH CONFIGURATION
# =====================================================

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

DATA_DIR = os.path.join(BASE_DIR, "data", "raw_images")
MODEL_DIR = os.path.join(BASE_DIR, "models")
GRAPH_DIR = os.path.join(BASE_DIR, "graphs")

os.makedirs(MODEL_DIR, exist_ok=True)
os.makedirs(GRAPH_DIR, exist_ok=True)

# =====================================================
# TRAINING CONFIGURATION
# =====================================================

IMG_SIZE = (224, 224)
BATCH_SIZE = 32
EPOCHS = 25
VALIDATION_SPLIT = 0.2
SEED = 42

MODEL_NAME = "mobilenetv2_model"

# =====================================================
# LOAD DATASET WITH AUTOMATIC SPLIT
# =====================================================

train_ds = keras.utils.image_dataset_from_directory(
    DATA_DIR,
    validation_split=VALIDATION_SPLIT,
    subset="training",
    seed=SEED,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE
)

val_ds = keras.utils.image_dataset_from_directory(
    DATA_DIR,
    validation_split=VALIDATION_SPLIT,
    subset="validation",
    seed=SEED,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE
)

class_names = train_ds.class_names
num_classes = len(class_names)

print("Detected classes:", class_names)
print("Total classes:", num_classes)

# Save labels
with open(os.path.join(MODEL_DIR, "labels.txt"), "w") as f:
    for label in class_names:
        f.write(label + "\n")

with open(os.path.join(MODEL_DIR, "labels.json"), "w") as f:
    json.dump(class_names, f, indent=4)

# =====================================================
# OPTIMIZE DATA LOADING
# =====================================================

AUTOTUNE = tf.data.AUTOTUNE

train_ds = train_ds.cache().shuffle(1000).prefetch(buffer_size=AUTOTUNE)
val_ds = val_ds.cache().prefetch(buffer_size=AUTOTUNE)

# =====================================================
# DATA AUGMENTATION
# =====================================================

data_augmentation = keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.08),
    layers.RandomZoom(0.1),
    layers.RandomContrast(0.1),
])

# =====================================================
# BUILD MOBILENETV2 MODEL
# =====================================================

base_model = keras.applications.MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights="imagenet"
)

base_model.trainable = False

inputs = keras.Input(shape=(224, 224, 3))
x = data_augmentation(inputs)
x = keras.applications.mobilenet_v2.preprocess_input(x)
x = base_model(x, training=False)
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dropout(0.4)(x)
x = layers.Dense(256, activation="relu")(x)
x = layers.Dropout(0.3)(x)
outputs = layers.Dense(num_classes, activation="softmax")(x)

model = keras.Model(inputs, outputs)

model.summary()

# =====================================================
# COMPILE MODEL
# =====================================================

model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=0.0001),
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"]
)

# =====================================================
# CALLBACKS
# =====================================================

callbacks = [
    keras.callbacks.EarlyStopping(
        monitor="val_accuracy",
        patience=5,
        restore_best_weights=True
    ),
    keras.callbacks.ModelCheckpoint(
        filepath=os.path.join(MODEL_DIR, f"{MODEL_NAME}_best.keras"),
        monitor="val_accuracy",
        save_best_only=True
    )
]

# =====================================================
# TRAIN MODEL
# =====================================================

history = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=EPOCHS,
    callbacks=callbacks
)

# =====================================================
# SAVE MODEL
# =====================================================

model.save(os.path.join(MODEL_DIR, f"{MODEL_NAME}.keras"))
model.save(os.path.join(MODEL_DIR, f"{MODEL_NAME}.h5"))

print(f"Model saved as {MODEL_NAME}.keras and {MODEL_NAME}.h5")

# =====================================================
# GENERATE GRAPHS
# =====================================================

acc = history.history["accuracy"]
val_acc = history.history["val_accuracy"]
loss = history.history["loss"]
val_loss = history.history["val_loss"]

epochs_range = range(1, len(acc) + 1)

plt.figure()
plt.plot(epochs_range, acc, label="Training Accuracy")
plt.plot(epochs_range, val_acc, label="Validation Accuracy")
plt.title("MobileNetV2 Accuracy")
plt.xlabel("Epoch")
plt.ylabel("Accuracy")
plt.legend()
plt.savefig(os.path.join(GRAPH_DIR, "mobilenetv2_accuracy.png"))
plt.close()

plt.figure()
plt.plot(epochs_range, loss, label="Training Loss")
plt.plot(epochs_range, val_loss, label="Validation Loss")
plt.title("MobileNetV2 Loss")
plt.xlabel("Epoch")
plt.ylabel("Loss")
plt.legend()
plt.savefig(os.path.join(GRAPH_DIR, "mobilenetv2_loss.png"))
plt.close()

print("MobileNetV2 training completed successfully.")
