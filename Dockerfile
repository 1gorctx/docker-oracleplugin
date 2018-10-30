FROM centos:7

LABEL maintainer "Igor Cunha <igorctx@gmail.com> and Leandro Avanço <leandro.avanco@gmail.com>"

ENV \
  yum_options="-y --setopt=tsflags=nodocs --nogpgcheck"

RUN mkdir /opt/zdba

WORKDIR /opt/zdba

COPY zdba.tar.gz ./

COPY oracle-instantclient*.rpm ./

RUN \
  yum_packages=" \
    libaio \
    curl \
    bzip2 \
    unzip \
    gcc \
    cpp \
    make \
    patch \
    perl-devel \
    perl-CPAN \
    perl-DBI \
    " && \
  yum $yum_options update && \
  yum makecache fast && \
  yum ${yum_options} install $yum_packages

RUN tar -zxvf zdba.tar.gz && \
    rpm -hiv ./oracle-instantclient*.rpm

RUN echo /usr/lib/oracle/18.3/client64/lib > /etc/ld.so.conf.d/oracle-instantclient18.3.conf && \
    ldconfig

ENV PATH $PATH:/usr/lib/oracle/18.3/client64/bin
ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/lib/oracle/18.3/client64/lib
ENV ORACLE_HOME /usr/lib/oracle/18.3/client64/lib
ENV NLS_LANG AMERICAN_AMERICA.UTF8

RUN (curl -L https://cpanmin.us | perl - App::cpanminus) && \
    cpanm --installdeps .

RUN ["cpanm", "DBD::Oracle"]

RUN rm -rf ./zdba.tar.gz && \
    rm -rf ./oracle-instantclient*.rpm && \
    yum clean all && rm -rf /var/cache/yum && rm -rf /tmp/*

VOLUME ["/opt/zdba/conf", "/opt/zdba/log"]

CMD ["/usr/bin/perl", "/opt/zdba/zdba.pl", "/opt/zdba/conf/config.pl"]
