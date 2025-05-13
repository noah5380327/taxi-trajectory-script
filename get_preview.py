import pandas as pd

file_path = "train.csv"
output_file = "preview.csv"

df = pd.read_csv(file_path, nrows=100)
df.to_csv(output_file, index=False)

print(f"get preview done: {output_file}")
