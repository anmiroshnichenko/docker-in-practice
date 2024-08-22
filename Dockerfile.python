FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt ./

RUN pip install --no-cache-dir -r requirements.txt

COPY main.py ./

#RUN apt-get update && apt-get install -y git

CMD ["python", "main.py"]
