import os

BASE_DIR = r"C:\Users\zahra\fyp_asl_system\ai_system\assets"

VIDEO_DIR = os.path.join(BASE_DIR, "signs_videos")
IMAGE_DIR = os.path.join(BASE_DIR, "signs_images")


def match_sign_output(text):
    text = text.lower().strip()
    words = text.split()

    outputs = []

    for word in words:
        video_path = os.path.join(VIDEO_DIR, f"{word}.mp4")

        # If word video exists, use video
        if os.path.exists(video_path):
            outputs.append({
                "type": "video",
                "path": video_path,
                "word": word
            })

        # If word video does not exist, spell using alphabet images
        else:
            for char in word:
                if char.isalpha():
                    image_path = os.path.join(IMAGE_DIR, f"{char}.png")

                    if os.path.exists(image_path):
                        outputs.append({
                            "type": "image",
                            "path": image_path,
                            "letter": char
                        })
                    else:
                        print("Missing image:", image_path)

    return {
        "text": text,
        "type": "mixed_output",
        "outputs": outputs
    }