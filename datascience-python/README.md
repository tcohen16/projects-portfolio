build_tfidf_word_list.py applies a TF-IDF–based approach to keyword extraction over collections of text data, treating each
input file as an individual document. The script computes inverse document frequency statistics across the full dataset to reduce the influence
of terms that appear broadly across documents, then calculates per-document TF-IDF scores to distinguish the most informative words in each subset.
From a data science perspective, this method supports comparative text analysis, and is well suited for identifying characteristic
vocabulary and generating meaningful textual features for clustering, or reporting.
