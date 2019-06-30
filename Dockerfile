FROM transfusion/ndk-r19c-gfortran-enabled

RUN apt update && apt install -y build-essential git wget cmake python

WORKDIR /root
# bake openblas into the image because it takes an awfully long time to compile
ADD ./build-android-openblas-aarch64.sh /root/
RUN chmod +x build-android-openblas-aarch64.sh
WORKDIR /root
RUN /root/build-android-openblas-aarch64.sh

RUN git clone https://github.com/project-spectra/glottal-inverse.git
WORKDIR /root/glottal-inverse
RUN mkdir bin
RUN git checkout without-amgif
RUN git checkout 9eb16410279a33cff19fed296c846adf9ab73c95
RUN git submodule update --init --recursive
RUN git submodule update --recursive --remote
ADD CMakeLists_Android-API24-aarch64.txt /root/glottal-inverse/
ADD build-android-arm64.sh /root/glottal-inverse/
RUN mv CMakeLists_Android-API24-aarch64.txt CMakeLists.txt