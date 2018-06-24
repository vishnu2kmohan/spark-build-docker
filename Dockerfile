# debian:9.4 - linux; amd64
# https://github.com/docker-library/repo-info/blob/master/repos/debian/tag-details.md#debian94---linux-amd64
FROM debian@sha256:316ebb92ca66bb8ddc79249fb29872bece4be384cb61b5344fac4e84ca4ed2b2

ARG BUILD_DATE
ARG CODENAME="stretch"
ARG CONDA_DIR="/opt/conda"
ARG CONDA_ENV_YML="spark-build-root-conda-base-env.yml"
ARG CONDA_INSTALLER="Miniconda3-4.5.4-Linux-x86_64.sh"
ARG CONDA_MD5="a946ea1d0c4a642ddf0c3a26a18bb16d"
ARG CONDA_URL="https://repo.continuum.io/miniconda"
ARG DCOS_COMMONS_URL="https://downloads.mesosphere.com/dcos-commons"
ARG DCOS_COMMONS_VERSION="0.50.0"
ARG DISTRO="debian"
ARG DEBCONF_NONINTERACTIVE_SEEN="true"
ARG DEBIAN_FRONTEND="noninteractive"
ARG GPG_KEYSERVER="hkps://zimmermann.mayfirst.org"
ARG HADOOP_HDFS_HOME="/opt/hadoop"
ARG HADOOP_MAJOR_VERSION="2.9"
ARG HADOOP_SHA256="eed6015a123644d3b4247bac58770e4a8b31340fa62721987430e15a0dd942fc"
ARG HADOOP_URL="http://www-us.apache.org/dist/hadoop/common"
ARG HADOOP_VERSION="2.9.1"
ARG HOME="/root"
ARG JAVA_HOME="/opt/jdk"
ARG JAVA_URL="https://downloads.mesosphere.com/java"
ARG JAVA_VERSION="8u172"
ARG LANG="en_US.UTF-8"
ARG LANGUAGE="en_US.UTF-8"
ARG LC_ALL="en_US.UTF-8"
ARG LIBMESOS_BUNDLE_SHA256="bd4a785393f0477da7f012bf9624aa7dd65aa243c94d38ffe94adaa10de30274"
ARG LIBMESOS_BUNDLE_URL="https://downloads.mesosphere.com/libmesos-bundle"
ARG LIBMESOS_BUNDLE_VERSION="1.11.0"
ARG MESOSPHERE_PREFIX="/opt/mesosphere"
ARG DEBIAN_REPO="http://cdn-fastly.deb.debian.org"
ARG SPARK_BUILD_VERSION="2.2.1-1.11.2"
ARG SBT_REPO="http://dl.bintray.com/sbt/debian"
ARG VCS_REF

LABEL maintainer="Vishnu Mohan <vishnu@mesosphere.com>" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.name="Spark Build" \
      org.label-schema.description="Apache Spark is a fast and general engine for large-scale data processing" \
      org.label-schema.url="http://spark.apache.org" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/mesosphere/spark-build" \
      org.label-schema.version="${SPARK_BUILD_VERSION}" \
      org.label-schema.schema-version="1.0"

ENV BOOTSTRAP="${MESOSPHERE_PREFIX}/bin/bootstrap" \
    CODENAME=${CODENAME:-"stretch"} \
    CONDA_DIR=${CONDA_DIR:-"/opt/conda"} \
    DEBCONF_NONINTERACTIVE_SEEN=${DEBCONF_NONINTERACTIVE_SEEN:-"true"} \
    DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-"noninteractive"} \
    DISTRO=${DISTRO:-"debian"} \
    GPG_KEYSERVER=${GPG_KEYSERVER:-"hkps://zimmermann.mayfirst.org"} \
    HADOOP_HDFS_HOME=${HADOOP_HDFS_HOME:-"/opt/hadoop"} \
    HOME=${HOME:-"/root"} \
    JAVA_HOME=${JAVA_HOME:-"/opt/jdk"} \
    LANG=${LANG:-"en_US.UTF-8"} \
    LANGUAGE=${LANGUAGE:-"en_US.UTF-8"} \
    LC_ALL=${LC_ALL:-"en_US.UTF-8"} \
    MAVEN_OPTS="-Xms4g -Xmx8g -XX:ReservedCodeCacheSize=2g" \
    MESOSPHERE_PREFIX=${MESOSPHERE_PREFIX:-"/opt/mesosphere"} \
    MESOS_AUTHENTICATEE="com_mesosphere_dcos_ClassicRPCAuthenticatee" \
    MESOS_HTTP_AUTHENTICATEE="com_mesosphere_dcos_http_Authenticatee" \
    MESOS_MODULES="{\"libraries\": [{\"file\": \"libdcos_security.so\", \"modules\": [{\"name\": \"com_mesosphere_dcos_ClassicRPCAuthenticatee\"}]}]}" \
    MESOS_NATIVE_LIBRARY="${MESOSPHERE_PREFIX}/libmesos-bundle/lib/libmesos.so" \
    MESOS_NATIVE_JAVA_LIBRARY="${MESOSPHERE_PREFIX}/libmesos-bundle/lib/libmesos.so" \
    PATH="${JAVA_HOME}/bin:${SPARK_HOME}/bin:${HADOOP_HDFS_HOME}/bin:${CONDA_DIR}/bin:${MESOSPHERE_PREFIX}/bin:${PATH}" \
    SHELL="/bin/bash"

RUN echo "deb ${DEBIAN_REPO}/${DISTRO} ${CODENAME} main" >> /etc/apt/sources.list \
    && echo "deb ${DEBIAN_REPO}/${DISTRO}-security ${CODENAME}/updates main" >> /etc/apt/sources.list \
    && echo "deb ${SBT_REPO} /" >> /etc/apt/sources.list.d/sbt.list \
    && apt-get update -yq --fix-missing \
    && apt-get install -yq --no-install-recommends apt-utils ca-certificates curl dirmngr gnupg locales \
    && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && apt-key adv --keyserver "${GPG_KEYSERVER}" --recv 2EE0EA64E40A89B84B2DF73499E82A75642AC823 \
    && apt-get update -yq --fix-missing \
    && apt-get -yq dist-upgrade \
    && apt-get install -yq --no-install-recommends \
       bash-completion \
       build-essential \
       bzip2 \
       dirmngr \
       dnsutils \
       git \
       jq \
       kstart \
       less \
       maven \
       netcat \
       nginx \
       openssh-client \
       procps \
       psmisc \
       r-base \
       rsync \
       runit \
       sbt \
       sssd \
       sudo \
       texlive \
       unzip \
       vim \
       wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && R -e "install.packages(c('knitr', 'rmarkdown', 'testthat', 'e1071', 'survival'), repos='http://cran.us.r-project.org')" \
    && addgroup --gid 99 nobody \
    && usermod -u 99 -g 99 nobody \
    && echo "nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin" >> /etc/passwd \
    && usermod -a -G users nobody

RUN cd /tmp \
    && mkdir -p "${CONDA_DIR}" "${HADOOP_HDFS_HOME}" "${JAVA_HOME}" "${MESOSPHERE_PREFIX}/bin" \
    && curl --retry 3 -fsSL -O "${LIBMESOS_BUNDLE_URL}/libmesos-bundle-${LIBMESOS_BUNDLE_VERSION}.tar.gz" \
    && echo "${LIBMESOS_BUNDLE_SHA256}" "libmesos-bundle-${LIBMESOS_BUNDLE_VERSION}.tar.gz" | sha256sum -c - \
    && tar xf "libmesos-bundle-${LIBMESOS_BUNDLE_VERSION}.tar.gz" -C "${MESOSPHERE_PREFIX}" \
    && cd /tmp \
    && curl --retry 3 -fsSL -O "${DCOS_COMMONS_URL}/artifacts/${DCOS_COMMONS_VERSION}/bootstrap.zip" \
    && unzip "bootstrap.zip" -d "${MESOSPHERE_PREFIX}/bin/" \
    && curl --retry 3 -fsSL -O "${JAVA_URL}/server-jre-${JAVA_VERSION}-linux-x64.tar.gz" \
    && tar xf "server-jre-${JAVA_VERSION}-linux-x64.tar.gz" -C "${JAVA_HOME}" --strip-components=1 \
    && curl --retry 3 -fsSL -O "${HADOOP_URL}/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" \
    && echo "${HADOOP_SHA256}" "hadoop-${HADOOP_VERSION}.tar.gz" | sha256sum -c - \
    && tar xf "hadoop-${HADOOP_VERSION}.tar.gz" -C "${HADOOP_HDFS_HOME}" --strip-components=1 \
    && rm -rf "${HADOOP_HDFS_HOME}/share/doc" \
    && rm -rf /tmp/*

COPY "${CONDA_ENV_YML}" "${CONDA_DIR}/"

RUN cd /tmp \
    && curl --retry 3 -fsSL -O "${CONDA_URL}/${CONDA_INSTALLER}" \
    && echo "${CONDA_MD5}  ${CONDA_INSTALLER}" | md5sum -c - \
    && bash "./${CONDA_INSTALLER}" -u -b -p "${CONDA_DIR}" \
    && ${CONDA_DIR}/bin/conda config --system --prepend channels conda-forge \
    && ${CONDA_DIR}/bin/conda config --system --set auto_update_conda false \
    && ${CONDA_DIR}/bin/conda config --system --set show_channel_urls true \
    && ${CONDA_DIR}/bin/conda update --json --all -yq \
    && ${CONDA_DIR}/bin/pip install --upgrade pip \
    && ${CONDA_DIR}/bin/conda env update --json -q -f "${CONDA_DIR}/${CONDA_ENV_YML}" \
    && rm -rf "${HOME}/.cache/pip" "${HOME}/.cache/yarn" "${HOME}/.node-gyp" \
    && ${CONDA_DIR}/bin/conda clean --json -tipsy \
    && rm -rf /tmp/*

COPY profile "/root/.profile"
COPY bash_profile "/root/.bash_profile"
COPY bashrc "/root/.bashrc"
COPY dircolors "/root/.dircolors"

RUN mv /usr/lib/x86_64-linux-gnu/libcurl.so.4.4.0 /usr/lib/x86_64-linux-gnu/libcurl.so.4.4.0.bak \
    && cp "${MESOSPHERE_PREFIX}/libmesos-bundle/lib/libcurl.so.4" /usr/lib/x86_64-linux-gnu/libcurl.so.4.4.0

ENV SPARK_DIST_CLASSPATH="${HADOOP_HDFS_HOME}/etc/hadoop:${HADOOP_HDFS_HOME}/share/hadoop/common/lib/*:${HADOOP_HDFS_HOME}/share/hadoop/common/*:${HADOOP_HDFS_HOME}/share/hadoop/hdfs:${HADOOP_HDFS_HOME}/share/hadoop/hdfs/lib/*:${HADOOP_HDFS_HOME}/share/hadoop/hdfs/*:${HADOOP_HDFS_HOME}/share/hadoop/yarn:${HADOOP_HDFS_HOME}/share/hadoop/yarn/lib/*:${HADOOP_HDFS_HOME}/share/hadoop/yarn/*:${HADOOP_HDFS_HOME}/share/hadoop/mapreduce/lib/*:${HADOOP_HDFS_HOME}/share/hadoop/mapreduce/*:${HADOOP_HDFS_HOME}/share/hadoop/tools/lib/*" \
    LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:${MESOSPHERE_PREFIX}/libmesos-bundle/lib:${JAVA_HOME}/jre/lib/amd64/server"

RUN ldconfig

COPY hadoop-env.sh "${HADOOP_HDFS_HOME}/etc/hadoop/"
COPY hadooprc "${HOME}/.hadooprc"
