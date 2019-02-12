FROM tomcat

MAINTAINER houssam

RUN apt-get update && apt-get -y upgrade

WORKDIR /usr/local/tomcat

EXPOSE 8080


FROM tesseract-ocr-compilation
RUN apt-get update && apt-get -y upgrade
WORKDIR /home
