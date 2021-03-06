FROM tomcat

MAINTAINER houssam

RUN apt-get update && apt-get -y upgrade

WORKDIR /usr/local/tomcat

EXPOSE 8080

RUN echo 'Done with TC, running Tesseract'

FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
	autoconf \
	autoconf-archive \
	automake \
	build-essential \
	checkinstall \
	cmake \
	g++ \
	git \
	libcairo2-dev \
	libicu-dev \
	libjpeg-dev \
	libpango1.0-dev \
	libgif-dev \
	libwebp-dev \
	libopenjp2-7-dev \
	libpng-dev \
	libtiff-dev \
	libtool \
	pkg-config \
	wget \
	xzgv \
	zlib1g-dev 

RUN echo 'SSH for diagnostic'
# SSH for diagnostic
RUN apt-get update && apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:troubl3tim3' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]

RUN echo 'Initializing Directories Env'

# Directories
ENV SCRIPTS_DIR /home/scripts
ENV PKG_DIR /home/pkg
ENV BASE_DIR /home/workspace
ENV LEP_REPO_URL https://github.com/DanBloomberg/leptonica.git
ENV LEP_SRC_DIR ${BASE_DIR}/leptonica
ENV TES_REPO_URL https://github.com/tesseract-ocr/tesseract.git
ENV TES_SRC_DIR ${BASE_DIR}/tesseract
ENV TESSDATA_PREFIX /usr/local/share/tessdata

RUN echo 'Creating Directories'

RUN mkdir ${SCRIPTS_DIR}
RUN mkdir ${PKG_DIR}
RUN mkdir ${BASE_DIR}
RUN mkdir ${TESSDATA_PREFIX}

#COPY ./container-scripts/* ${SCRIPTS_DIR}/

RUN echo 'Running repos_clone'

RUN chmod +x ${SCRIPTS_DIR}/*
#RUN ${SCRIPTS_DIR}/repos_clone.sh
#!/bin/bash

RUN echo 'Running Downloading source code'

# Downloading source code
# Leptonica
# RUN git ls-remote ${LEP_REPO_URL} HEAD
RUN git clone ${LEP_REPO_URL} ${LEP_SRC_DIR}
# Tesseract
# RUN git ls-remote ${TES_REPO_URL} HEAD
RUN git clone ${TES_REPO_URL} ${TES_SRC_DIR}
RUN echo 'Done Downloading source code'


RUN echo 'Running tessdata_download'
#RUN ${SCRIPTS_DIR}/tessdata_download.sh

# osd	Orientation and script detection
RUN wget -O ${TESSDATA_PREFIX}/osd.traineddata https://github.com/tesseract-ocr/tessdata/raw/3.04.00/osd.traineddata
# equ	Math / equation detection
RUN wget -O ${TESSDATA_PREFIX}/equ.traineddata https://github.com/tesseract-ocr/tessdata/raw/3.04.00/equ.traineddata
# eng English
RUN wget -O ${TESSDATA_PREFIX}/eng.traineddata https://github.com/tesseract-ocr/tessdata/raw/4.00/eng.traineddata
# other languages: https://github.com/tesseract-ocr/tesseract/wiki/Data-Files

RUN echo 'Done'
WORKDIR /home
