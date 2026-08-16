import speech_recognition as sr

recognizer = sr.Recognizer()

print("Available microphones:")
for index, name in enumerate(sr.Microphone.list_microphone_names()):
    print(index, name)

with sr.Microphone() as source:
    print("\nAdjusting for background noise...")
    recognizer.adjust_for_ambient_noise(source, duration=1)

    print("Speak now...")
    audio = recognizer.listen(source)

try:
    text = recognizer.recognize_google(audio)
    print("You said:", text)

except sr.UnknownValueError:
    print("Sorry, I could not understand the audio.")

except sr.RequestError:
    print("Speech recognition service error. Check internet connection.")