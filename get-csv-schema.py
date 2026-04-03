import sys
from pathlib import Path
import pandas as pd

# 1. Load a sample of your CSV (you don't need the whole thing)
# file_path = './data/your_file.csv' 
if not sys.argv[1:]:
    print(f'SYNTAX: {sys.argv[0]} path/to/csv')
    exit(1)

file_path = Path(sys.argv[1])

if not file_path.resolve().exists():
    print(f'path does not exists: {str(file_path)!r}')
    exit(2)


df = pd.read_csv(file_path, nrows=100) # Only look at the first 100 rows

# 2. Clean up column names (SQL doesn't like spaces or special characters)
df.columns = [c.replace(' ', '_').replace('.', '').strip() for c in df.columns]

# 3. Generate the CREATE TABLE statement
# 'dummy_table' is just a placeholder name
schema = pd.io.sql.get_schema(df, 'YourTableName')

print("--- COPY AND PASTE THIS INTO VS CODE MSSQL ---")
print(schema)

