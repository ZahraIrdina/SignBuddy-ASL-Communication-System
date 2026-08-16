import re


def clean_text(text):
    text = text.lower()
    text = re.sub(r"[^a-zA-Z0-9\s]", "", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def tokenize_text(text):
    cleaned_text = clean_text(text)
    tokens = cleaned_text.split()
    return tokens


def text_to_key(text):
    cleaned_text = clean_text(text)
    key = cleaned_text.replace(" ", "_")
    return key


if __name__ == "__main__":
    sample_text = input("Enter sentence: ")

    cleaned = clean_text(sample_text)
    tokens = tokenize_text(sample_text)
    key = text_to_key(sample_text)

    print("Original:", sample_text)
    print("Cleaned:", cleaned)
    print("Tokens:", tokens)
    print("Video Key:", key)