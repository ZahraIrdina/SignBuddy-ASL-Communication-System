class SentenceBuilder:
    def __init__(self):
        self.sentence = ""

    def add_letter(self, letter):
        self.sentence += letter
        return self.sentence

    def add_space(self):
        self.sentence += " "
        return self.sentence

    def delete_last(self):
        self.sentence = self.sentence[:-1]
        return self.sentence

    def clear(self):
        self.sentence = ""
        return self.sentence

    def get_sentence(self):
        return self.sentence


if __name__ == "__main__":
    builder = SentenceBuilder()

    print("Sentence Builder Test")
    print("Type letter to add")
    print("Type SPACE for space")
    print("Type DELETE to delete last character")
    print("Type CLEAR to clear sentence")
    print("Type EXIT to quit")

    while True:
        user_input = input("Input: ").strip()

        if user_input.upper() == "EXIT":
            break
        elif user_input.upper() == "SPACE":
            builder.add_space()
        elif user_input.upper() == "DELETE":
            builder.delete_last()
        elif user_input.upper() == "CLEAR":
            builder.clear()
        elif len(user_input) == 1:
            builder.add_letter(user_input.upper())
        else:
            print("Invalid input.")

        print("Sentence:", builder.get_sentence())