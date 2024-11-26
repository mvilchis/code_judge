import redis
import boto3


# Cambiar a config file
redis_client = redis.Redis(host='redis', port=6379)
minio_client = boto3.client('s3',endpoint_url='http://minio:9000',
                            aws_access_key_id='minioadmin',
                            aws_secret_access_key='minioadmin')
bucket_name = "practicas"

def download_document(self, file_name):
    try:
        response = self.minio_client.get_object(Bucket=self.bucket_name, Key=file_name)
        local_path = f"/Tester/Languages/JAVA/Compiler/{file_name}"
        with open(local_path, 'wb') as file:
            file.write(response['Body'].read())

        print(f"Documento {file_name} descargado y guardado en {local_path}.")
        return local_path
    except Exception as e:
        print(f"Error al descargar el documento {file_name}: {e}")
        return None

def execute_java_file(self, script_path):
    try:
        print(f"Ejecutando el script: {script_path}")
        exit_code = os.system(f"make {script_path}")
        if exit_code == 0:
            print(f"Script {script_path} ejecutado con éxito.")
        else:
            print(f"Error al ejecutar el script {script_path}. Código de salida: {exit_code}")
    except Exception as e:
        print(f"Error durante la ejecución del script {script_path}: {e}")

def process_document(self, file_name):
    script_path = self.download_document(file_name)
    if script_path and script_path.endswith('.java'):
        self.execute_script(script_path)



if __name__ == "__main__":
    while True:
        task = redis_client.blpop('task_queue', timeout=0)
        if task:
            _, file_name = task
            process_document(file_name.decode('utf-8'))
