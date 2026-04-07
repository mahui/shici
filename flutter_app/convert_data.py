#!/usr/bin/env python3
"""Convert text poetry data to JSON for Flutter app."""

import json
import os
import sys

TEXT_DIR = os.path.join(os.path.dirname(__file__), '..', 'web', 'src', 'main', 'resources', 'text')
OUTPUT_FILE = os.path.join(os.path.dirname(__file__), 'assets', 'data', 'poems.json')


def parse_meta(meta_path):
    """Parse meta.txt file for poet info."""
    birth = ''
    death = ''
    bio = ''
    if not os.path.exists(meta_path):
        return birth, death, bio
    with open(meta_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    bio_lines = []
    for line in lines:
        line_stripped = line.strip()
        if line_stripped.startswith('birth='):
            birth = line_stripped[6:]
        elif line_stripped.startswith('death='):
            death = line_stripped[6:]
        elif line_stripped:
            bio_lines.append(line_stripped)
    bio = '\n'.join(bio_lines)
    return birth, death, bio


def parse_poem(poem_path):
    """Parse a poem file."""
    form = ''
    tags = ''
    content_lines = []
    with open(poem_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    header_done = False
    blank_after_header = False
    for line in lines:
        stripped = line.strip()
        if not header_done:
            if stripped.startswith('form='):
                form = stripped[5:]
                continue
            elif stripped.startswith('tags='):
                tags = stripped[5:]
                continue
            elif stripped == '':
                if form or tags:
                    header_done = True
                continue
            else:
                header_done = True
        if header_done:
            content_lines.append(line.rstrip())
    content = '\n'.join(content_lines).strip()
    return form, tags, content


def main():
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)

    data = {"dynasties": []}

    dynasty_dirs = sorted(os.listdir(TEXT_DIR))
    for dynasty_dir in dynasty_dirs:
        dynasty_path = os.path.join(TEXT_DIR, dynasty_dir)
        if not os.path.isdir(dynasty_path):
            continue

        # Extract dynasty name (remove numbering prefix like "01.")
        dynasty_name = dynasty_dir
        if '.' in dynasty_name:
            dynasty_name = dynasty_name.split('.', 1)[1]

        dynasty = {
            "name": dynasty_name,
            "poets": []
        }

        poet_dirs = sorted(os.listdir(dynasty_path))
        for poet_dir in poet_dirs:
            poet_path = os.path.join(dynasty_path, poet_dir)
            if not os.path.isdir(poet_path):
                continue

            meta_path = os.path.join(poet_path, 'meta.txt')
            birth, death, bio = parse_meta(meta_path)

            poet = {
                "name": poet_dir,
                "birth": birth,
                "death": death,
                "bio": bio,
                "poems": []
            }

            poem_files = sorted(os.listdir(poet_path))
            for poem_file in poem_files:
                if poem_file == 'meta.txt':
                    continue
                if not poem_file.endswith('.txt'):
                    continue
                poem_path = os.path.join(poet_path, poem_file)
                title = poem_file[:-4]  # Remove .txt
                form, tags, content = parse_poem(poem_path)
                if content:
                    poet["poems"].append({
                        "title": title,
                        "form": form,
                        "tags": tags,
                        "content": content
                    })

            if poet["poems"]:
                dynasty["poets"].append(poet)

        if dynasty["poets"]:
            data["dynasties"].append(dynasty)

    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, separators=(',', ':'))

    # Print stats
    total_poets = sum(len(d["poets"]) for d in data["dynasties"])
    total_poems = sum(len(p["poems"]) for d in data["dynasties"] for p in d["poets"])
    print(f"Converted {total_poems} poems from {total_poets} poets across {len(data['dynasties'])} dynasties")
    file_size = os.path.getsize(OUTPUT_FILE)
    print(f"Output file size: {file_size / 1024 / 1024:.1f} MB")


if __name__ == '__main__':
    main()
