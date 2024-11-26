import redis
import time
from minio import Minio
from minio.error import S3Error

# Cambiar a config file
redis_client = redis.Redis(host='redis', port=6379)
minio_client = Minio('minio:9000',
                     access_key='minioadmin',
                     secret_key='minioadmin',
                     secure=False
                     )

bucket_name = "practicas"

def create_bucket():
    if not minio_client.bucket_exists(bucket_name):
        minio_client.make_bucket(bucket_name)

def generate_and_upload_document(task_id):
    content = f"Contenido del documento para {task_id}"
    # Subimos la misma practica
    minio_client.fput_object(bucket_name, "Test17.java",
                            "/app/Test17.java")

    print(f"Documento Test17.java subido a MinIO")
    return "Test17.java"

def send_task(task):
    redis_client.rpush('task_queue', task)
    print(f'Tarea enviada: {task}')

if __name__ == "__main__":
    create_bucket()
    count = 0
    while True:
        task_id = f"Task-{count}"
        file_name = generate_and_upload_document(task_id)
        send_task(file_name)
        count += 1
        time.sleep(20)  # Envía una tarea cada 20 segundos
