from transformers import AutoTokenizer

TEST_SENTENCE = "Tested sentence to encode."
tokenizer = AutoTokenizer.from_pretrained("mistralai/Mistral-7B-v0.1")

tokens = tokenizer.tokenize(TEST_SENTENCE)

print(" ".join(tokens))
print(tokenizer(TEST_SENTENCE))
