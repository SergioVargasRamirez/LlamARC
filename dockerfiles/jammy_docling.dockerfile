FROM ubuntu:jammy AS jammy.docling

SHELL ["/bin/bash", "-l", "-c"]

#prep the system
RUN apt-get update
RUN apt-get install -y pip

RUN pip install --upgrade pip

RUN pip install docling-serve[ui]

WORKDIR /data

#CMD docling-serve run --enable-ui
