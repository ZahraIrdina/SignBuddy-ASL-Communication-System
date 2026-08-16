import speech_recognition as sr


def listen_and_convert():
    recognizer = sr.Recognizer()

    with sr.Microphone() as source:
        print("Adjusting background noise...")
        recognizer.adjust_for_ambient_noise(source, duration=1)

        print("Listening... Speak now.")
        audio = recognizer.listen(source)

    try:
        text = recognizer.recognize_google(audio)
        return text

    except sr.UnknownValueError:
        return ""

    except sr.RequestError:
        print("Speech recognition service error.")
        return ""


if __name__ == "__main__":
    result = listen_and_convert()

    if result:
        print("Recognized Text:", result)
    else:
        print("No speech detected.")