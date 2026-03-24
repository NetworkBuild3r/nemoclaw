FROM python:3.12-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY panos_client.py mcp_server.py main.py .

ENV MCP_PORT=8765
ENV PANOS_MOCK=1

EXPOSE 8765

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8765/health')"

CMD ["python", "main.py"]
