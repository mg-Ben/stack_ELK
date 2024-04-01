ARG STACK_VERSION

FROM docker.elastic.co/elasticsearch/elasticsearch:${STACK_VERSION}

#The ARGs must be defined after FROM as FROM initializes a new image. Otherwise, arg values will be empty string:
#https://stackoverflow.com/questions/60450479/using-arg-and-env-in-dockerfile

ARG CA_Password
ARG CA_CertificateName
ARG Node_Password
ARG Node_TLS_CertificateName

#TLS/SSL for inter-node communication:
RUN ./bin/elasticsearch-certutil ca --silent --pass ${CA_Password} -out /usr/share/elasticsearch/config/${CA_CertificateName}
RUN ./bin/elasticsearch-certutil cert --silent --ca /usr/share/elasticsearch/config/${CA_CertificateName} --ca-pass ${CA_Password} --pass ${Node_Password} -out /usr/share/elasticsearch/config/${Node_TLS_CertificateName};

CMD ["/bin/bash", "./bin/elasticsearch"]