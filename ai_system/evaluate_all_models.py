import os
import numpy as np
import pandas as pd
import tensorflow as tf
import matplotlib.pyplot as plt
import seaborn as sns

from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    confusion_matrix,
    classification_report
)

# ==========================================================
# CONFIGURATION
# ==========================================================

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

DATASET_PATH = os.path.join(BASE_DIR, "data", "raw_images")

MODEL_PATHS = {
    "CNN": os.path.join(BASE_DIR, "models", "cnn_model.keras"),
    "MobileNetV2": os.path.join(BASE_DIR, "models", "mobilenetv2_model.keras"),
    "EfficientNet": os.path.join(BASE_DIR, "models", "efficientnet_model.keras")
}

RESULT_DIR = os.path.join(BASE_DIR, "evaluation", "results")
os.makedirs(RESULT_DIR, exist_ok=True)

IMG_SIZE = (64, 64)
BATCH_SIZE = 32

# ==========================================================
# LOAD TEST DATASET
# ==========================================================

print("=" * 60)
print("Loading Dataset...")
print("=" * 60)

test_dataset = tf.keras.preprocessing.image_dataset_from_directory(
    DATASET_PATH,
    validation_split=0.2,
    subset="validation",
    seed=42,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    shuffle=False
)

class_names = test_dataset.class_names

print("\nClasses:")
print(class_names)

# ==========================================================
# GET TRUE LABELS
# ==========================================================

y_true = np.concatenate(
    [labels.numpy() for _, labels in test_dataset],
    axis=0
)

# ==========================================================
# STORE RESULTS
# ==========================================================

all_results = []

# ==========================================================
# EVALUATE EACH MODEL
# ==========================================================

for model_name, model_path in MODEL_PATHS.items():

    print("\n" + "=" * 60)
    print(f"Evaluating {model_name}")
    print("=" * 60)

    if not os.path.exists(model_path):
        print(f"Model not found: {model_path}")
        continue

    # Load model
    model = tf.keras.models.load_model(model_path)

    # Prediction
    predictions = model.predict(test_dataset, verbose=1)

    y_pred = np.argmax(predictions, axis=1)

    # Metrics
    accuracy = accuracy_score(y_true, y_pred)

    precision = precision_score(
        y_true,
        y_pred,
        average='weighted',
        zero_division=0
    )

    recall = recall_score(
        y_true,
        y_pred,
        average='weighted',
        zero_division=0
    )

    f1 = f1_score(
        y_true,
        y_pred,
        average='weighted',
        zero_division=0
    )

    print(f"\nAccuracy  : {accuracy:.4f}")
    print(f"Precision : {precision:.4f}")
    print(f"Recall    : {recall:.4f}")
    print(f"F1 Score  : {f1:.4f}")

    # Save result
    all_results.append({
        "Model": model_name,
        "Accuracy": accuracy,
        "Precision": precision,
        "Recall": recall,
        "F1 Score": f1
    })

    # ======================================================
    # CLASSIFICATION REPORT
    # ======================================================

    report = classification_report(
    y_true,
    y_pred,
    labels=list(range(len(class_names))),
    target_names=class_names,
    zero_division=0
)

    report_file = os.path.join(
        RESULT_DIR,
        f"{model_name}_classification_report.txt"
    )

    with open(report_file, "w") as f:
        f.write(report)

    print("\nClassification Report Saved")

    # ======================================================
    # CONFUSION MATRIX
    # ======================================================

    cm = confusion_matrix(
    y_true,
    y_pred,
    labels=list(range(len(class_names)))
)

    plt.figure(figsize=(14, 12))

    sns.heatmap(
        cm,
        cmap="Blues",
        xticklabels=class_names,
        yticklabels=class_names
    )

    plt.title(f"{model_name} Confusion Matrix")
    plt.xlabel("Predicted")
    plt.ylabel("Actual")

    plt.tight_layout()

    plt.savefig(
        os.path.join(
            RESULT_DIR,
            f"{model_name}_confusion_matrix.png"
        )
    )

    plt.close()

    print("Confusion Matrix Saved")

# ==========================================================
# COMPARISON TABLE
# ==========================================================

results_df = pd.DataFrame(all_results)

results_df = results_df.sort_values(
    by="Accuracy",
    ascending=False
)

print("\n")
print("=" * 60)
print("MODEL COMPARISON")
print("=" * 60)

print(results_df)

results_df.to_csv(
    os.path.join(
        RESULT_DIR,
        "model_comparison.csv"
    ),
    index=False
)

# ==========================================================
# BAR CHART COMPARISON
# ==========================================================

results_df.set_index("Model")[
    ["Accuracy", "Precision", "Recall", "F1 Score"]
].plot(
    kind="bar",
    figsize=(10, 6)
)

plt.title("Model Performance Comparison")
plt.ylabel("Score")
plt.ylim(0, 1)

plt.tight_layout()

plt.savefig(
    os.path.join(
        RESULT_DIR,
        "model_comparison_chart.png"
    )
)

plt.close()

print("\nEvaluation Complete!")
print("Results saved in:", RESULT_DIR)