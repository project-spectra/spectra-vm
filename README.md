Builds the `gif.Android_ARM64` binary from a modified Ubuntu 18.04.2 LTS Docker image; also some pseudo-documentation on what dependencies are required.

# Instructions

Ensure you have docker installed. 

```bash
mkdir output
# this bootstraps the docker image containing all the dependencies.
# the git repo, without-amgif branch is baked into the image for now.
docker build -t spectra_android-api24-aarch64_build_debug .

docker run -it --volume "$PWD/output:/root/glottal-inverse/bin" spectra_android-api24-aarch64_build_debug:latest bash /root/glottal-inverse/build-android-arm64.sh
```
The `gif.Android_ARM64` binary along with `libgfortran.so` and `libopenblas.so` should be present in the `output` folder on your host.

```sh
:~/spectra-vm/output$ ~/Android/Sdk/platform-tools/adb shell
sagit:/ $ mkdir -p /data/local/tmp/glottal-inverse
sagit:/ $ ^D
:~/spectra-vm/output$ ~/Android/Sdk/platform-tools/adb push * /data/local/tmp/glottal-inverse/
gif.Android_ARM64: 1 file pushed. 17.1 MB/s (581736 bytes in 0.033s)
libgfortran.so: 1 file pushed. 19.6 MB/s (4290408 bytes in 0.209s)
libopenblas.so: 1 file pushed. 17.9 MB/s (11309320 bytes in 0.601s)
3 files pushed. 18.1 MB/s (16181464 bytes in 0.852s)
:~/spectra-vm/output$ ~/Android/Sdk/platform-tools/adb shell
sagit:/ $ su
sagit:/ # cd /data/local/tmp/glottal-inverse
sagit:/data/local/tmp/glottal-inverse # ls
gif.Android_ARM64  libgfortran.so  libopenblas.so  
sagit:/data/local/tmp/glottal-inverse # chmod +x gif.Android_ARM64                                                                                                                                            
sagit:/data/local/tmp/glottal-inverse # ./gif.Android_ARM64                                                                                                                                                   
 ==== Starting ====
 ==== Exiting safely ====

  (*) Final estimations:
      - Mean VTL: -1.0 cm 
oboe: unable to close input stream: ErrorClosed
Segmentation fault

...

:~/spectra-vm/output$ ~/Android/Sdk/platform-tools/adb push /home/transfusion/glottal-inverse/mini_aplawd/as05c1.egg.wav /data/local/tmp/glottal-inverse/
/home/transfusion/glottal-inverse/mini_aplawd/as05c1.egg.wav: 1 file pushed. 5.5 MB/s (82844 bytes in 0.014s)
:~/spectra-vm/output$ ~/Android/Sdk/platform-tools/adb shell
sagit:/ $ su
sagit:/ # cd /data/local/tmp/glottal-inverse
sagit:/data/local/tmp/glottal-inverse # ./gif.Android_ARM64 as05c1.egg.wav                                                                                                                                    
fileio: reading "as05c1.egg.wav" 20000 Hz f.32
 ==== Starting ====

  (*) Estimated:
      - f0: 487 Hz
      - VTL: -1.0 cm
      - Oq: 0.00

  (*) Estimated:
      - f0: 487 Hz
      - VTL: -1.0 cm
      - Oq: 0.00

  (*) Estimated:
      - f0: 103 Hz
      - VTL: -1.0 cm
      - Oq: 0.00

  (*) Estimated:
      - f0: 103 Hz
      - VTL: -1.0 cm
      - Oq: 0.00

  (*) Estimated:
      - f0: 125 Hz
      - VTL: -1.0 cm
      - Oq: 0.00

  (*) Estimated:
      - f0: 126 Hz
      - VTL: -1.0 cm
      - Oq: 0.00

  (*) Estimated:
      - f0: 111 Hz
      - VTL: -1.0 cm
      - Oq: 0.00

  (*) Estimated:
      - f0: 119 Hz
      - VTL: -1.0 cm
      - Oq: 0.00

  (*) Estimated:
      - f0: 129 Hz
      - VTL: -1.0 cm
      - Oq: 0.00

  (*) Estimated:
      - f0: 133 Hz
      - VTL: -1.0 cm
      - Oq: 0.00

  (*) Estimated:
      - f0: 119 Hz
      - VTL: -1.0 cm
      - Oq: 0.00

  (*) Estimated:
      - f0: 102 Hz
      - VTL: -1.0 cm
      - Oq: 0.00

  (*) Estimated:
      - f0: 100 Hz
      - VTL: -1.0 cm
      - Oq: 0.00

  (*) Estimated:
      - f0: 102 Hz
      - VTL: -1.0 cm
      - Oq: 0.00
 ==== Exiting safely ====

  (*) Final estimations:
      - Mean VTL: -1.0 cm

```

## Caveats and other known issues
Rewrite the CMakeLists.txt with the `if(TARGET_ARCH MATCHES "^Android")` block properly and merge it into master.

## Dependencies

```
$ readelf -d gif.Android_ARM64 

Dynamic section at offset 0x70b38 contains 33 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libgfortran.so]
 0x0000000000000001 (NEEDED)             Shared library: [liblog.so]
 0x0000000000000001 (NEEDED)             Shared library: [libc++_shared.so]
 0x0000000000000001 (NEEDED)             Shared library: [libOpenSLES.so]
 0x0000000000000001 (NEEDED)             Shared library: [libdl.so]
 0x0000000000000001 (NEEDED)             Shared library: [libopenblas.so]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so]
 0x000000000000001d (RUNPATH)            Library runpath: [.:/root/android-toolchain-standalone-r19-gfortran/aarch64-linux-android-4.9/aarch64-linux-android/lib64:/root/OpenBLAS/build/lib]
```
The standalone toolchain containing `aarch64-linux-android-gfortran` was built according to this guide. https://github.com/buffer51/android-gfortran . The sysroot (including `crtbegin_dynamic.o`) and the STL being linked with is still that of NDK r19c downloaded from the Android developer site (`Pkg.Revision = 19.2.5345600`) because the toolchain output using `./build.py --toolchain arm-linux-androideabi` is incomplete and only includes the binaries.

`libgfortran.so` is created manually from `libgfortran.a`, a static library output by `./build.py` during generation of the gfortran toolchain. This is possible because it was compiled with `-fPIC` . `libopenblas.so` when compiled dynamically depends on it. 

```bash
$ echo $_SYSROOT
/home/transfusion/Android/Sdk/ndk-bundle/platforms/android-24/arch-arm64
ar -x libgfortran.a
$ pwd
/home/transfusion/android-toolchain-built/aarch64-linux-android-4.9/aarch64-linux-android/lib64
../../../bin/aarch64-linux-android-gcc --sysroot=$_SYSROOT -shared *.o -o libgfortran.so
```

Inside the image (I have done the same for `arm-linux-androideabi` too):
```bash
:~/android-toolchain-standalone-r19-gfortran/aarch64-linux-android-4.9/aarch64-linux-android/lib64# ls
libatomic.a  libgfortran.a  libgfortran.so  libgfortran.spec  libgfortran_conversion  libgomp.a  libgomp.spec
```



## TODO
- 32-bit builds.
- Add a script that allows switching between Debug or Release mode.
- Do not bake the src into the repo - read it through a bind mount from the host.
- Statically link OpenBLAS and libgfortran.