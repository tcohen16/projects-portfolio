import json
import re
import argparse
from collections import Counter
from math import log

def load_stop_words(file_path):
    """Load stop words from a file."""
    with open(file_path, "r") as file:
        return set(line.strip().lower() for line in file)

def tokenize(text):
    """Tokenize and clean text."""
    return re.findall(r'\b\w+\b', text.lower())

def compute_tf(word_counts, total_words):
    """Compute term frequency (TF)."""
    return {word: count / total_words for word, count in word_counts.items()}

def compute_idf(documents):
    """Compute inverse document frequency (IDF)."""
    idf = {}
    total_docs = len(documents)
    all_words = set(word for doc in documents for word in doc)
    for word in all_words:
        doc_count = sum(1 for doc in documents if word in doc)
        idf[word] = log(total_docs / (1 + doc_count))  # Smoothing to avoid division by zero
    return idf

def compute_tfidf(tf, idf):
    """Compute TF-IDF scores."""
    return {word: tf[word] * idf[word] for word in tf}

def get_tfidf_scores(file_path, idf, stop_words=None, top_n=10):
    """Get the top N words based on TF-IDF scores for a given file."""
    with open(file_path, "r") as file:
        data = json.load(file)
    
    # Validate JSON structure
    if not isinstance(data, dict) or "data" not in data or "children" not in data["data"]:
        raise ValueError(f"Unexpected JSON structure in {file_path}")
    
    # Extract titles
    children = data["data"]["children"]
    titles = " ".join([child["data"].get("title", "") for child in children])
    words = tokenize(titles)
    if stop_words:
        words = [word for word in words if word not in stop_words and len(word) > 1]

    # Compute TF
    word_counts = Counter(words)
    total_words = sum(word_counts.values())
    tf = compute_tf(word_counts, total_words)

    # Compute TF-IDF
    tfidf_scores = compute_tfidf(tf, idf)
    return sorted(tfidf_scores.items(), key=lambda x: x[1], reverse=True)[:top_n]

def main():
    parser = argparse.ArgumentParser(description="Compute TF-IDF scores for words in input files.")
    parser.add_argument("-o", "--output", required=True, help="Output JSON file to store results.")
    parser.add_argument("-s", "--stopwords", help="Optional stopword file.")
    parser.add_argument("input_files", nargs="+", help="List of input JSON files.")
    args = parser.parse_args()

    # Load stop words if provided
    stop_words = load_stop_words(args.stopwords) if args.stopwords else None

    # Load all documents for IDF computation
    documents = []
    for input_file in args.input_files:
        with open(input_file, "r") as file:
            data = json.load(file)
            if not isinstance(data, dict) or "data" not in data or "children" not in data["data"]:
                raise ValueError(f"Unexpected JSON structure in {input_file}")
            children = data["data"]["children"]
            titles = " ".join([child["data"].get("title", "") for child in children])
            words = tokenize(titles)
            if stop_words:
                words = [word for word in words if word not in stop_words and len(word) > 1]
            documents.append(words)
    
    # Compute IDF
    idf = compute_idf(documents)

    # Compute TF-IDF for each file
    results = {}
    for input_file in args.input_files:
        results[input_file] = get_tfidf_scores(input_file, idf, stop_words)

    # Write results to output file
    with open(args.output, "w") as outfile:
        json.dump(results, outfile, indent=4)

if __name__ == "__main__":
    main()