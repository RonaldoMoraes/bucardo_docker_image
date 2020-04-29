FROM ubuntu:xenial

LABEL maintainer="ronaldo.moraes1990@gmail.com"
LABEL version="1.0"

RUN apt-get -y update \
    && apt-get -y upgrade

# Setting timzeone on env
ENV TZ=America/Sao_Paulo

# Creating timezone based on env
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get -y install postgresql-9.5 bucardo jq

COPY etc/pg_hba.conf /etc/postgresql/9.5/main/
COPY etc/bucardorc /etc/bucardorc

RUN chown postgres /etc/postgresql/9.5/main/pg_hba.conf
RUN chown postgres /etc/bucardorc
RUN chown postgres /var/log/bucardo
RUN mkdir /var/run/bucardo && chown postgres /var/run/bucardo
RUN usermod -aG bucardo postgres

RUN service postgresql start \
    && su - postgres -c "bucardo install --batch"

COPY lib/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose postgres
EXPOSE 5432

VOLUME "/media/bucardo"
CMD ["/bin/bash","-c","/entrypoint.sh"]
