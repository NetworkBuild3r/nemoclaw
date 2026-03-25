FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY snow_client.py mcp_server.py main.py .

ENV MCP_PORT=8766
ENV SNOW_MOCK=1

EXPOSE 8766

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8766/health')"

CMD ["python", "main.py"]
