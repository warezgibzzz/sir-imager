FROM ubuntu:latest
RUN curl -sSL https://dist.crystal-lang.org/apt/setup.sh | bash
RUN sudo apt install crystal shards libssl-dev libxml2-dev libyaml-dev libgmp-dev libreadline-dev
