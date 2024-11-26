FROM ubuntu:20.04
#FROM openjdk:24

RUN apt-get update &&\
    apt-get install unzip -y &&\
    apt-get install python3 -y &&\
    apt install python3-distutils -y &&\
    apt-get install python3-dev -y &&\
    apt-get install openjdk-8-jdk -y

RUN apt-get install python3-pip -y


RUN pip install redis boto3 minio


#Sandbox files
ADD backend /
RUN cd Tester/Languages/JAVA/Sandbox && make


# Code
WORKDIR /app
COPY worker.py .


CMD ["python", "worker.py"]
