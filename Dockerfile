FROM debian:9.9

# we need cmake with min version 3.10
ADD https://github.com/Kitware/CMake/releases/download/v3.14.5/cmake-3.14.5-Linux-x86_64.sh /cmake-3.14.5-Linux-x86_64.sh
RUN mkdir /opt/cmake
RUN sh /cmake-3.14.5-Linux-x86_64.sh --prefix=/opt/cmake --skip-license
RUN ln -s /opt/cmake/bin/cmake /usr/local/bin/cmake
RUN cmake --version

RUN apt update && apt install -y build-essential git wget

# install armadillo
RUN mkdir libarmadillo9_build
ADD https://sources.voidlinux.org/armadillo-9.200.8/armadillo-9.200.8.tar.xz /libarmadillo9_build/armadillo-9.200.8.tar.xz
WORKDIR /libarmadillo9_build
RUN tar -xf armadillo-9.200.8.tar.xz
WORKDIR /libarmadillo9_build/armadillo-9.200.8
RUN ./configure && make -j4 && make install

WORKDIR /

RUN git clone https://github.com/project-spectra/glottal-inverse.git
WORKDIR /glottal-inverse
RUN git checkout without-amgif
ADD disable-stack-protection.patch /glottal-inverse/
RUN git apply disable-stack-protection.patch
RUN mkdir bin
RUN mkdir build && cd build && cmake .. -DCMAKE_BUILD_TYPE=Debug

# should already install libsoundio1
RUN apt install -y libsoundio-dev libopenblas-dev libpulse-dev portaudio19-dev libgfortran-6-dev

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
