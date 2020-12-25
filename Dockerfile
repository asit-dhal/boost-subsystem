FROM ubuntu:18.04
MAINTAINER Asit Dhal <dhal.asitk@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y \
    gcc build-essential \
    software-properties-common \
    wget \
    apt-utils \
    tar

RUN mkdir -p /work/boost_download && \
	mkdir -p /work/boost_src

RUN wget --progress=bar:force:noscroll https://dl.bintray.com/boostorg/release/1.75.0/source/boost_1_75_0.tar.gz -P /work/boost_download && \
	tar -zxvf /work/boost_download/boost_1_75_0.tar.gz --directory /work/boost_src

RUN cd /work/boost_src/boost_1_75_0 && \
    ./bootstrap.sh && \
    ./b2 tools/bcp

COPY ./gen.sh /work/scripts/gen

RUN chmod +x /work/scripts/gen

WORKDIR /work/boost_src/boost_1_75_0/

ENV PATH="${PATH}:/work/boost_src/boost_1_75_0:/work/boost_src/boost_1_75_0/dist/bin:/work/scripts"

#ENTRYPOINT ["bcp", "--boost=/work/boost_src/boost_1_75_0", "build", "bootstrap.bat", "bootstrap.sh", "boostcpp.jam", "boost-build.jam"]