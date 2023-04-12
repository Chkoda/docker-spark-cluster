FROM openjdk:11.0.11-jre-slim-buster as builder

# Add Dependencies for PySpark
RUN apt-get update && apt-get install -y curl vim wget cifs-utils software-properties-common ssh net-tools ca-certificates python3 python3-pip python3-numpy python3-matplotlib python3-scipy python3-pandas python3-simpy

RUN update-alternatives --install "/usr/bin/python" "python" "$(which python3)" 1

# Fix the value of PYTHONHASHSEED
# Note: this is needed when you use Python 3.3 or greater
ENV SPARK_VERSION=3.3.2 \
SCALA_VERSION=2.13 \
SPARK_HOME=/opt/spark \
PYTHONHASHSEED=1

RUN wget --no-verbose -O apache-spark.tgz "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3-scala${SCALA_VERSION}.tgz" \
&& mkdir -p /opt/spark \
&& tar -xf apache-spark.tgz -C /opt/spark --strip-components=1 \
&& rm apache-spark.tgz


FROM builder as apache-spark

WORKDIR /opt/spark

ENV SPARK_MASTER_PORT=7077 \
SPARK_MASTER_WEBUI_PORT=8080 \
SPARK_LOG_DIR=/opt/spark/logs \
SPARK_WORKER_WEBUI_PORT=8080 \
SPARK_WORKER_PORT=7000

EXPOSE 8080 4040 7077 7000 10015

RUN mkdir -p $SPARK_LOG_DIR && \
touch $SPARK_LOG_DIR/$SPARK_LOCAL_IP.out && \
ln -sf /dev/stdout $SPARK_LOG_DIR/$SPARK_LOCAL_IP.out

COPY start-spark.sh /

CMD ["/bin/bash", "/start-spark.sh"]
