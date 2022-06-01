FROM ubuntu:20.04
RUN apt update \
    && apt install -y python3 \
    && apt install -y python3-pip \
    && apt install -y git \
    && apt install -y net-tools \
    && apt install -y curl \
    && pip3 install mlflow==1.24.0 \
    && pip3 install protobuf~=3.19.0 \
    && pip3 install boto3==1.23.10 \
    && pip3 install scikit-learn==1.0.2 \
    && pip3 install pymysql==1.0.2 \
    && mkdir -p /mlflow/ \
    && rm -rf ~/.cache/pip \

WORKDIR /ai

COPY /model/ /ai/ai_service/models/boston_housing_model/

CMD mlflow models serve \
    --model-uri /ai/ai_service/models/boston_housing_model \
    --port 8080 \
    --host 0.0.0.0 \
    --no-conda
