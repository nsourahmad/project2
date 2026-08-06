FROM python:3.14-slim
 
WORKDIR /app
 
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
&& rm -rf /var/lib/apt/lists/*
 
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir python-dotenv gunicorn
 
COPY . /app/Expense_Tracker
 
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app
ENV FLASK_APP=server.py
 
EXPOSE 8000
 
WORKDIR /app/Expense_Tracker/backend
 
CMD ["flask", "run", "--host=0.0.0.0", "--port=8000"]
