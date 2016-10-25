FROM centos:6
MAINTAINER rmkn
RUN localedef -f UTF-8 -i ja_JP ja_JP.utf8 && sed -i -e "s/en_US.UTF-8/ja_JP.UTF-8/" /etc/sysconfig/i18n
RUN cp -p /usr/share/zoneinfo/Japan /etc/localtime && echo 'ZONE="Asia/Tokyo"' > /etc/sysconfig/clock
RUN yum -y update
RUN yum -y install gcc pcre-devel zlib-devel

ENV NGINX_VERSION 1.10.1
ENV LIBRESSL_VERSION 2.4.2

RUN curl -o /usr/local/src/libressl.tar.gz -SL http://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRESSL_VERSION}.tar.gz \
	&& tar zxf /usr/local/src/libressl.tar.gz -C /usr/local/src \
	&& cd /usr/local/src/libressl-${LIBRESSL_VERSION} \
	&& ./configure \
	&& make \
	&& make install

RUN curl -o /usr/local/src/nginx.tar.gz -SL https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
	&& tar zxf /usr/local/src/nginx.tar.gz -C /usr/local/src \
	&& cd /usr/local/src/nginx-${NGINX_VERSION} \
	&& ./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-ld-opt="-lrt" --with-openssl=/usr/local/src/libressl-${LIBRESSL_VERSION} \
	&& make \
	&& make install

COPY nginx.conf /usr/local/nginx/conf/nginx.conf
COPY virtual.conf /usr/local/nginx/conf/conf.d/virtual.conf

EXPOSE 80

CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
