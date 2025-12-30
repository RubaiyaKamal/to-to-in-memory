import os
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()
api_key = os.environ.get("OPENAI_API_KEY")
print(f"Testing Key: {api_key[:10]}...")

try:
    client = OpenAI(api_key=api_key)
    client.models.list()
    print("SUCCESS: API Key is valid.")
except Exception as e:
    print(f"FAILURE: {e}")
