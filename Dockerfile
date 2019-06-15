FROM debian:9.9

# we need cmake with min version 3.10
ADD https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5-Linux-x86_64.sh /cmake-3.14.5-Linux-x86_64.sh
RUN mkdir /opt/cmake
RUN sh /cmake-3.14.5-Linux-x86_64.sh --prefix=/opt/cmake --skip-license
RUN ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake
RUN cmake --version

RUN echo "deb http://deb.debian.org/debian buster main" >> /etc/apt/sources.list
RUN echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list

RUN echo "deb http://deb.debian.org/debian buster-updates main" >> /etc/apt/sources.list
RUN echo "deb-src http://deb.debian.org/debian buster-updates main" >> /etc/apt/sources.list

RUN echo "deb http://security.debian.org/ buster/updates main contrib non-free" >> /etc/apt/sources.list
RUN echo "deb-src http://security.debian.org/ buster/updates main contrib non-free" >> /etc/apt/sources.list

# install the packaging tools too because we need to build libarmadillo9 from buster repos
RUN apt update && apt install -y build-essential packaging-dev debian-keyring devscripts equivs git wget

# install armadillo
RUN mkdir libarmadillo9_build
WORKDIR /libarmadillo9_build
RUN apt source -t buster armadillo=1:9.200.7+dfsg-1
RUN ls
WORKDIR /libarmadillo9_build/armadillo-9.200.7+dfsg
RUN ls
RUN yes Y | sudo mk-build-deps --install; exit 0
RUN rm armadillo-build-deps*.deb
RUN dpkg-buildpackage -us -uc
WORKDIR /libarmadillo9_build
RUN dpkg -i libarmadillo9*.deb libarmadillo*.deb; exit 0
RUN yes Y | apt-get -f install

WORKDIR /

RUN git clone https://github.com/project-spectra/glottal-inverse.git
WORKDIR /glottal-inverse
RUN git checkout without-amgif
ADD disable-stack-protection.patch /glottal-inverse/
RUN git apply disable-stack-protection.patch
RUN mkdir bin
RUN mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Debug

# should already install libsoundio1
RUN apt install -y libsoundio-dev libopenblas-dev libpulse-dev portaudio19-dev libgfortran-8-dev

# WORKDIR /glottal-inverse/build
# RUN make -j4
# WORKDIR /glottal-inverse/bin
# we're in the bin folder now.
# RUN ldd gif.Linux | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp -v '{}' ./

# echo the script to build into the image

RUN echo "cd /glottal-inverse/build" >> /glottal-inverse/build-docker-debian-99.sh
RUN echo "make -j4" >> /glottal-inverse/build-docker-debian-99.sh
RUN echo "cd ../bin" >> /glottal-inverse/build-docker-debian-99.sh
RUN echo "ldd gif.Linux | grep \"=> /\" | awk '{print \$3}' | xargs -I '{}' cp -v '{}' ./" >> /glottal-inverse/build-docker-debian-99.sh
