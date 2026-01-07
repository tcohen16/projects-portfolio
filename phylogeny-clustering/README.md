This project implements 2 data science sub-projects grounded in NLP and linguistic data. In the first part, the code uses the NorthEuraLex lexical database
to study relationships between Indo-European languages by treating wordforms as the underlying data. It preprocesses and merges lexical metadata,
computes pairwise similarity scores based on edit distance between languages' wordforms, and summarizes these similarities. The analysis then applies clustering methods
to infer a language family tree, which is compared against known linguistic subfamilies for validation. In the second part, the code focuses on an acoustic analysis task,
where vowels without labels are analyzed using k-means clustering and Gaussian Mixture Models, with model selection guided by silhouette scores and BIC,
to estimate the number and structure of vowel categories in a "mystery" language. Together, the sub-projects demonstrate how linguistic data can be
transformed into numerical representations and analyzed to reveal structure in both lexical and acoustic domains.
