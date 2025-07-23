FROM python:3-slim AS slim_docling

#RUN apt-get update
#RUN apt-get install -y pip
RUN pip install --upgrade pip
RUN pip install docling-serve[ui]
WORKDIR /data
CMD docling-serve run --enable-ui