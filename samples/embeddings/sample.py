import openai
import os
import re
import requests
import sys
from num2words import num2words
import pandas as pd
import numpy as np
from openai.embeddings_utils import get_embedding, cosine_similarity
import tiktoken

API_KEY = os.getenv("OPENAI_API_KEY")
RESOURCE_ENDPOINT = os.getenv("OPENAI_RESOURCE_ENDPOINT")

openai.api_type = "azure"
openai.api_key = os.getenv("OPENAI_API_KEY")
