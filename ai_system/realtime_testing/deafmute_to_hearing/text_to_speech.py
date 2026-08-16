import pyttsx3

engine = pyttsx3.init()

engine.setProperty("rate", 150)
engine.setProperty("volume", 1.0)

def speak_text(text):
    if text.strip() == "":
        print("No text to speak.")
        return

    print(f"Speaking: {text}")
    engine.say(text)
    engine.runAndWait()


if __name__ == "__main__":
    text = input("Enter text to speak: ")
    speak_text(text)