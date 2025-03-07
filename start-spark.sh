#!/bin/bash

find /drivers -name "*.jar" -type f -exec cp {} /opt/spark/jars \;

. "/opt/spark/bin/load-spark-env.sh"

if [ "$SPARK_WORKLOAD" == "master" ];
then
  export SPARK_MASTER_HOST=`hostname`
  cd /opt/spark &&
  $(sleep 10 && ./sbin/start-thriftserver.sh --master spark://$SPARK_MASTER_HOST:7077) &
  ./bin/spark-class org.apache.spark.deploy.master.Master --ip $SPARK_MASTER_HOST --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT >> $SPARK_LOG_DIR/$SPARK_LOCAL_IP.out
elif [ "$SPARK_WORKLOAD" == "worker" ];
then
  cd /opt/spark/bin && ./spark-class org.apache.spark.deploy.worker.Worker --webui-port $SPARK_WORKER_WEBUI_PORT $SPARK_MASTER >> $SPARK_LOG_DIR/$SPARK_LOCAL_IP.out
elif [ "$SPARK_WORKLOAD" == "submit" ];
then
  echo "SPARK SUBMIT"
else
  echo "Undefined Workload Type $SPARK_WORKLOAD, must specify: master, worker, submit"
fi
