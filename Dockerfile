FROM google/cloud-sdk:alpine

WORKDIR /app

# Install wget
RUN  apk add krb5-libs && \
     apk add --no-cache wget

# Install mongodb tools
RUN wget https://fastdl.mongodb.org/tools/db/mongodb-database-tools-amazon2-x86_64-100.9.5.tgz && \
    tar -zxvf mongodb-database-tools-*-100.9.5.tgz && \
    cp ./mongodb-database-tools-amazon2-x86_64-100.9.5/bin/* /usr/local/bin/

# Copy scripts and launch Python server
COPY mongo-backups.sh .

RUN chmod +x mongo-backups.sh

COPY server.py .

ENTRYPOINT ["/usr/bin/python3", "server.py"]
