# FROM alpine:3

# RUN apk add gcc
# RUN apk add gfortran
# RUN apk add gsl
# RUN apk add netcdf

RUN wget https://www.libradtran.org/download/libRadtran-2.0.6.tar.gz
RUN tar -xzf libRadtran-2.0.6.tar.gz
RUN cd libRadtran-2.0.6/ &&

FROM redhat/ubi9-minimal

RUN microdnf install gcc
RUN microdnf install gfortran
# RUN microdnf install gsl
# RUN microdnf install netcdf



FROM ubuntu

RUN apt-get update

RUN apt-get -y install make
RUN apt-get -y install gcc
RUN apt-get -y install g++
RUN apt-get -y install gfortran
RUN apt-get -y install libgsl-dev
RUN apt-get -y install libnetcdf-dev
RUN apt-get -y install wget
RUN apt-get -y install python3
RUN apt-get -y install gawk
RUN apt-get -y install perl-modules-5.38

# $(find / -name 'gsl_math.h')
RUN export CPPFLAGS="-I/usr/include/gsl"
# $(find / -name 'libgsl.so')
RUN export LDFLAGS="-L/usr/lib/aarch64-linux-gnu"

RUN LIBRADTRAN_PACKAGE=libRadtran-2.0.6
RUN wget https://www.libradtran.org/download/$LIBRADTRAN_PACKAGE.tar.gz
RUN tar -xzf $LIBRADTRAN_PACKAGE.tar.gz --transform s/^$LIBRADTRAN_PACKAGE/libradtran/

RUN cd libradtran
RUN ./configure --with-libnetcdf=/usr/include
RUN make
RUN make check

RUN alias uvspec="/libradtran/bin/uvspec"

ENV LD_LIBRARY_PATH=/usr/include/gsl/lib/

RUN LMU_URL=https://www.meteo.physik.uni-muenchen.de
RUN REPTRAN_PACKAGE=reptran-2024-all.tar.gz
RUN wget "${LMU_URL}/~libradtran/lib/exe/fetch.php?media=download:${REPTRAN_PACKAGE//-/_}" -O $REPTRAN_PACKAGE

# NOTE: Some files already exist in data/reptran
RUN tar -xzf $REPTRAN_PACKAGE -C /libradtran

# RUN apt-get remove --purge wget

# Setup an app user so the container doesn't run as the root user
RUN useradd app
USER app

# CMD ["/libradtran/bin/uvspec", "<", "a.inp", ">", "a.out"]
