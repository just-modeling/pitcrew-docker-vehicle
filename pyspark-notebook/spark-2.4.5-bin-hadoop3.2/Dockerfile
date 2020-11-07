ARG SPARK_IMAGE=gcr.io/spark-operator/spark:v2.4.5
FROM ${SPARK_IMAGE}

ARG VERSION
ARG VCS_REF
ARG BUILD_DATE

ENV SCALA_VERSION 2.11
ENV SPARK_VERSION 2.4.5
ENV HADOOP_VERSION 3.2.1
#ENV KUBERNETES_CLIENT_VERSION 4.6.4

ENV REPO_URL http://central.maven.org/maven2
ENV ARCHIVE_URL http://archive.apache.org/dist

# Adhere to opencontainers image spec https://github.com/opencontainers/image-spec/blob/master/annotations.md
LABEL org.opencontainers.image.title="graphiq-spark-runner" \
      org.opencontainers.image.created=${BUILD_DATE} \
      org.opencontainers.image.description="base image for Scala  Spark jobs that need to run on kubernetes via the spark-operator" \
      org.opencontainers.image.source="https://github.com/TomLous/medium-spark-k8s" \
      org.opencontainers.image.documentation="https://github.com/TomLous/medium-spark-k8s/blob/master/README.md" \
      org.opencontainers.image.revison=${VCS_REF} \
      org.opencontainers.image.vendor="GraphIQ" \
      org.opencontainers.image.version=${VERSION} \
      org.opencontainers.image.authors="Tom Lous <tomlous@gmail.com>" \
      version.scala=${SCALA_VERSION} \
      version.spark=${SPARK_VERSION} \
      version.hadoop=${HADOOP_VERSION} \
      version.kubernetes-client=${KUBERNETES_CLIENT_VERSION}

# Install Tools
RUN apt update && apt install -y curl ssh git vim gcc

# Hadoop Config
ENV HADOOP_HOME "/opt/hadoop"
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


## Kubernetes Client  <= TODO Remove when this issue is fixed https://andygrove.io/2019/08/apache-spark-regressions-eks/
#RUN rm -rf ${SPARK_HOME}/jars/kubernetes-*.jar
#ADD ${REPO_URL}/io/fabric8/kubernetes-client/${KUBERNETES_CLIENT_VERSION}/kubernetes-client-${KUBERNETES_CLIENT_VERSION}.jar ${SPARK_HOME}/jars
#ADD ${REPO_URL}/io/fabric8/kubernetes-model/${KUBERNETES_CLIENT_VERSION}/kubernetes-model-${KUBERNETES_CLIENT_VERSION}.jar ${SPARK_HOME}/jars
#ADD ${REPO_URL}/io/fabric8/kubernetes-model-common/${KUBERNETES_CLIENT_VERSION}/kubernetes-model-common-${KUBERNETES_CLIENT_VERSION}.jar ${SPARK_HOME}/jars

# Edit entrypoint to source spark-env.sh before running spark-submit
RUN sed -i '30i #CUSTOM\n' /opt/entrypoint.sh \
    && sed -i '/#CUSTOM/a source ${SPARK_HOME}/conf-org/spark-env.sh\n' /opt/entrypoint.sh

#RUN mkdir ${SPARK_HOME}/python
# TODO: Investigate running both pip and pip3 via virtualenvs
RUN apt install -y python python-pip && \
    apt install -y python3 python3-pip && \
    # We remove ensurepip since it adds no functionality since pip is
    # installed on the image and it just takes up 1.6MB on the image
    rm -r /usr/lib/python*/ensurepip && \
    pip install --upgrade pip setuptools && \
    # You may install with python3 packages by using pip3.6
    # Removed the .cache to save space
    rm -r /root/.cache && rm -rf /var/cache/apt/*


#COPY spark-2.4.5-bin-hadoop2.7/python/lib ${SPARK_HOME}/python/lib
ENV PYTHONPATH ${SPARK_HOME}/python/lib/pyspark.zip:${SPARK_HOME}/python/lib/py4j-*.zip

## Install python3 packages
RUN pip3 install \
	pyarrow==0.14.0 \
	pandas==0.25.0 \
	numpy==1.17.0 \
	snappy \
	Cython==0.29.15 \
	azure-storage-file-datalake \
	junit-xml \
	adal

WORKDIR /opt/spark/work-dir

ENTRYPOINT ["/opt/entrypoint.sh"]