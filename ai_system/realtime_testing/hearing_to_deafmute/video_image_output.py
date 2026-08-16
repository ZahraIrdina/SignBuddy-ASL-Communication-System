import os
import cv2
import time
from speech_to_text import listen_and_convert
from sign_matcher import match_sign_output


def display_image(image_path, delay=1.2):
    image = cv2.imread(image_path)

    if image is None:
        print("Cannot open image:", image_path)
        return

    cv2.imshow("Sign Image Output", image)
    cv2.waitKey(int(delay * 1000))


def play_video(video_path):
    cap = cv2.VideoCapture(video_path)

    if not cap.isOpened():
        print("Cannot open video:", video_path)
        return

    print("Playing video:", video_path)

    while True:
        ret, frame = cap.read()

        if not ret:
            break

        cv2.imshow("Sign Video Output", frame)

        if cv2.waitKey(25) & 0xFF == ord("q"):
            break

    cap.release()
    cv2.destroyWindow("Sign Video Output")


def show_sign_output(result):
    outputs = result["outputs"]

    print("\nRecognized Text:", result["text"])
    print("Output Type:", result["type"])

    if not outputs:
        print("No matching sign output found.")
        return

    for item in outputs:
        if item["type"] == "video":
            play_video(item["path"])

        elif item["type"] == "image":
            print("Showing:", item["path"])
            display_image(item["path"])

    cv2.destroyAllWindows()


def main():
    print("Hearing to Deaf-Mute System")
    print("1. Speak using microphone")
    print("2. Type text manually")

    choice = input("Choose option 1 or 2: ").strip()

    if choice == "1":
        text = listen_and_convert()

        if not text:
            print("No speech recognized.")
            return

    elif choice == "2":
        text = input("Enter text: ").strip()

    else:
        print("Invalid option.")
        return

    result = match_sign_output(text)
    show_sign_output(result)

    print("\nProcess completed.")


if __name__ == "__main__":
    main()