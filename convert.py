import json

file_content = []
with open("pwned-passwords-sha1-ordered-by-count-v6.txt") as f:
    for line in f:
        passwordhash, occurences = line.strip().split(":", maxsplit=1)
        file_content.append({"passwordhash": passwordhash, "occurences": occurences})
        # print(passwordhash,occurences)
print(json.dumps(file_content))
