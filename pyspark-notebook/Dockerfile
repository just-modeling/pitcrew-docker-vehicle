# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER
FROM $BASE_CONTAINER as system

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

USER root

RUN apt-get -y update && \
    apt-get install --no-install-recommends -y openjdk-8-jre-headless ca-certificates-java && \
    rm -rf /var/lib/apt/lists/*

# Mesos dependencies
# Install from the Xenial Mesosphere repository since there does not (yet)
# exist a Bionic repository and the dependencies seem to be compatible for now.
COPY mesos.key /tmp/
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y gnupg && \
    apt-key add /tmp/mesos.key && \
    echo "deb http://repos.mesosphere.io/ubuntu xenial main" > /etc/apt/sources.list.d/mesosphere.list && \
    apt-get -y update && \
    apt-get --no-install-recommends -y install mesos=1.2\* && \
    apt-get purge --auto-remove -y gnupg && \
    rm -rf /var/lib/apt/lists/*

# Install Tools
RUN apt-get update && apt-get install -y curl ssh git vim gcc

################################################################################
# spark builder
################################################################################
FROM gcr.io/spark-operator/spark:v2.4.5 as builder

ENV SCALA_VERSION 2.11
ENV SPARK_VERSION 2.4.5
ENV HADOOP_VERSION 3.2.1
ENV REPO_URL http://central.maven.org/maven2
ENV ARCHIVE_URL http://archive.apache.org/dist

# Install Tools
RUN apt update && apt install -y curl ssh git vim gcc

# Hadoop Config
ENV HADOOP_HOME /opt/hadoop
RUN rm -rf ${HADOOP_HOME}/ \
    && cd /opt \
    && curl -sL --retry 3 "${ARCHIVE_URL}/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" | tar xz  \
    && chown -R root:root hadoop-${HADOOP_VERSION} \
    && ln -sfn hadoop-${HADOOP_VERSION} hadoop \
    && rm -rf ${HADOOP_HOME}/share/doc \
    && find /opt/ -name *-sources.jar -delete
ENV PATH="${HADOOP_HOME}/bin:${PATH}"
ENV HADOOP_CONF_DIR "${HADOOP_HOME}/etc/hadoop"

# Spark Config
# Since the conf/ folder gets mounted over by the spark-operator we move the spark-env.sh to another folder to be sourced in the entrypoint.sh. No good solution exists to merge the original conf folder with the volumeMount
RUN rm -rf ${SPARK_HOME}/ \
    && cd /opt \
    #&& curl -sL --retry 3 "${ARCHIVE_URL}/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop-scala-${SCALA_VERSION}.tgz" | tar xz  \
    #&& mv spark-${SPARK_VERSION}-bin-without-hadoop-scala-${SCALA_VERSION} spark-${SPARK_VERSION} \
    && curl -sL --retry 3 "${ARCHIVE_URL}/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz" | tar xz  \
    && mv spark-${SPARK_VERSION}-bin-without-hadoop spark-${SPARK_VERSION} \
    && chown -R root:root spark-${SPARK_VERSION} \
    && ln -sfn spark-${SPARK_VERSION} spark \
    && mkdir -p ${SPARK_HOME}/conf-org/ \
    && mv ${SPARK_HOME}/conf/spark-env.sh.template ${SPARK_HOME}/conf-org/spark-env.sh \
    && rm -rf ${SPARK_HOME}/examples  ${SPARK_HOME}/data ${SPARK_HOME}/tests ${SPARK_HOME}/conf  \
    && echo 'export SPARK_DIST_CLASSPATH=$(hadoop classpath):/opt/hadoop/share/hadoop/tools/*:/opt/hadoop/share/hadoop/tools/lib/*' >> ${SPARK_HOME}/conf-org/spark-env.sh \
    && echo 'export SPARK_EXTRA_CLASSPATH=$(hadoop classpath):/opt/hadoop/share/hadoop/tools/*:/opt/hadoop/share/hadoop/tools/lib/*' >> ${SPARK_HOME}/conf-org/spark-env.sh

ENV PATH="${SPARK_HOME}/bin:${PATH}"


################################################################################
# merge
################################################################################
FROM system
# Spark and Mesos config
ENV SPARK_HOME /opt/spark
ENV HADOOP_HOME /opt/hadoop
ENV PATH="${HADOOP_HOME}/bin:${PATH}"
ENV PATH="${SPARK_HOME}/bin:${PATH}"
ENV HADOOP_CONF_DIR "${HADOOP_HOME}/etc/hadoop"

COPY --from=builder /opt/spark /opt/spark
COPY --from=builder /opt/hadoop /opt/hadoop

ENV JAVA_HOME=/usr
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-*.zip:${SPARK_HOME}/python/lib/pyspark.zip"
ENV PYSPARK_PYTHON=/opt/conda/bin/python
ENV SPARK_DIST_CLASSPATH="/opt/hadoop/etc/hadoop:/opt/hadoop/share/hadoop/common/lib/*:/opt/hadoop/share/hadoop/common/*:/opt/hadoop/share/hadoop/hdfs:/opt/hadoop/share/hadoop/hdfs/lib/*:/opt/hadoop/share/hadoop/hdfs/*:/opt/hadoop/share/hadoop/mapreduce/lib/*:/opt/hadoop/share/hadoop/mapreduce/*:/opt/hadoop/share/hadoop/yarn:/opt/hadoop/share/hadoop/yarn/lib/*:/opt/hadoop/share/hadoop/yarn/*:/opt/hadoop/share/hadoop/tools/*:/opt/hadoop/share/hadoop/tools/lib/*"
ENV SPARK_EXTRA_CLASSPATH="/opt/hadoop/etc/hadoop:/opt/hadoop/share/hadoop/common/lib/*:/opt/hadoop/share/hadoop/common/*:/opt/hadoop/share/hadoop/hdfs:/opt/hadoop/share/hadoop/hdfs/lib/*:/opt/hadoop/share/hadoop/hdfs/*:/opt/hadoop/share/hadoop/mapreduce/lib/*:/opt/hadoop/share/hadoop/mapreduce/*:/opt/hadoop/share/hadoop/yarn:/opt/hadoop/share/hadoop/yarn/lib/*:/opt/hadoop/share/hadoop/yarn/*:/opt/hadoop/share/hadoop/tools/*:/opt/hadoop/share/hadoop/tools/lib/*"
ENV MESOS_NATIVE_LIBRARY /usr/local/lib/libmesos.so
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

USER $NB_UID

## Install findspark
RUN pip install \
    findspark \
    pyarrow==0.14.0 \
	snappy \
	azure-storage-file-datalake \
	junit-xml \
	adal

COPY jupyter_notebook_config.py /etc/jupyter/

USER root
RUN mkdir -p /opt/spark/conf
COPY spark-defaults.conf /opt/spark/conf/spark-defaults.conf

USER $NB_UID

EXPOSE 9998