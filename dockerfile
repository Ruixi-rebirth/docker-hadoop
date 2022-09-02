FROM continuumio/anaconda3 
RUN useradd -d /home/hadoop/ -m hadoop \
    && echo root:ruixi | chpasswd \
    && echo hadoop:ruixi | chpasswd
WORKDIR /home/hadoop 
COPY .ssh ./.ssh
COPY jupyterlab.sh ./ 
COPY sshd.sh ./ 
COPY start-process.sh* ./ 
RUN set -x; pkg='wget iputils-ping iproute2 vim ranger openssh-server openssh-client sudo' \
    && apt update 2> /dev/null \
    && apt install -y $pkg 2> /dev/null \
    && conda install jupyter -y --quiet \
    && mkdir jdk hadoop spark notebooks \
    && wget http://23.105.207.7:8888/jdk-11.0.16_linux-x64_bin.tar.gz \
    && wget http://23.105.207.7:8888/spark.tar.gz \
    && wget http://23.105.207.7:8888/hadoop.tar.gz \
    && tar -zxf jdk-11.0.16_linux-x64_bin.tar.gz -C jdk --strip-components=1 \
    && tar -zxf hadoop.tar.gz -C hadoop --strip-components=1 \
    && tar -zxf spark.tar.gz -C spark --strip-components=1 \
    && rm jdk-11.0.16_linux-x64_bin.tar.gz spark.tar.gz hadoop.tar.gz \
    && sed -i "s/#PermitRootLogin yes/PermitRootLogin yes/g" /etc/ssh/sshd_config \
    && sed -i -e '$ahadoop ALL=(ALL) NOPASSWD: NOPASSWD: ALL' /etc/sudoers \
    && sed -i -e '$asudo service ssh start' .bashrc \
    && sed -i -e '$ajupyter notebook --notebook-dir=/home/hadoop/notebooks --ip='*' --port=27649 --no-browser --allow-root' .bashrc \
    && chown -R hadoop:hadoop .ssh \
    && chmod 600 ./.ssh/id_rsa \
    && mv spark/sbin/start-all.sh spark/sbin/start-all-spark.sh \
    && mv spark/sbin/stop-all.sh spark/sbin/stop-all-spark.sh \
    && chown -R hadoop:hadoop * 
USER hadoop
ENV JAVA_HOME /home/hadoop/jdk
ENV CLASSPATH $JAVA_HOME/lib 
ENV SPARK_HOME=/home/hadoop/spark
ENV HADOOP_HOME /home/hadoop/hadoop 
ENV PATH $JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:.:$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
#RUN hdfs namenode -format \ 
#    && start-dfs.sh \
#    && start-yarn.sh \
#    && mapred --daemon start historyserver

