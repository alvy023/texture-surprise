import json
import sys

def markdown_to_json_string(markdown_filepath):
    with open(markdown_filepath, 'r', encoding='utf-8') as f:
        markdown_content = f.read()
    
    # Return just the content, properly escaped for shell usage
    return markdown_content

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python3 stringify_markdown.py <markdown_file>", file=sys.stderr)
        sys.exit(1)
    
    content = markdown_to_json_string(sys.argv[1])
    print(content, end='')