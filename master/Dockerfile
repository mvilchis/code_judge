# Usa una imagen de Python como base
FROM python:3.9-slim

# Establece el directorio de trabajo
WORKDIR /app

# Copia el código de la aplicación
COPY app.py .
COPY Test17.java .

# Instala las dependencias
RUN pip install redis boto3 minio

# Define el comando por defecto para ejecutar la app
CMD ["python", "app.py"]
