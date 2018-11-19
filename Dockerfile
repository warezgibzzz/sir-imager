FROM ubuntu:bionic

RUN apt update && apt install -y curl gnupg
RUN curl -sL "https://keybase.io/crystal/pgp_keys.asc" | apt-key add -
RUN echo "deb https://dist.crystal-lang.org/apt crystal main" | tee /etc/apt/sources.list.d/crystal.list
RUN apt update && apt install -y crystal libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev

WORKDIR /data
VOLUME [ "/data/public/uploads" ]
ADD . .
RUN shards install
EXPOSE 80
EXPOSE 8888
RUN crystal build src/sir-imager.cr

ENTRYPOINT /data/sir-imager