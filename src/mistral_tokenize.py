from transformers import AutoTokenizer

TEST_SENTENCE = "Tested sentence to encode."
tokenizer = AutoTokenizer.from_pretrained("mistralai/Mistral-7B-v0.1")

print(tokenizer.tokenize(TEST_SENTENCE))
print(tokenizer(TEST_SENTENCE))
