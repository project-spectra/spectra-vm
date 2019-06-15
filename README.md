Builds the `gif.Linux` binary from a Debian Stretch Docker image; also some pseudo-documentation on what dependencies are required.

# Instructions

Ensure you have docker installed. 

```bash
mkdir output
# this bootstraps the docker image containing all the dependencies.
# the git repo, without-amgif branch is baked into the image for now.
docker build -t spectra_debian9.9_build_debug .

docker run -it --volume "$PWD/output:/glottal-inverse/bin" spectra_debian9.9_build_debug:latest bash /glottal-inverse/build-docker-debian-99.sh
```
The `gif.Linux` binary with all recursive dependencies should be present in the `output` folder on your host. Perhaps you may need to `sudo chown -R user:user output` where user is the name of your local user. To run the `gif.Linux` binary (overriding LD_LIBRARY_PATH is a must in order to use the binaries taken from the Debian image, or else you will encounter `error while loading shared libraries`):

```
$ LD_LIBRARY_PATH=`pwd` ./gif.Linux
soundio: selected device: Monitor of Built-in Audio Digital Stereo (HDMI)
soundio: Mono 48000 Hz float 32-bit LE
 ==== Starting ====
```

## Caveats and other known issues
- Trying to run `gif.Linux` on Ubuntu 18.04.2 LTS results in 
```
*** stack smashing detected ***: <unknown> terminated
Aborted (core dumped)
```
Cause: Debian 9 is ancient; and one of the libraries is compiled without stack protection.

Workaround: Delete all the other `.so` files besides `libpulsecommon-12.2.so` and `libpulse.so.0`. You will need to install the other libraries manually on your host. The resulting binary should run.

```
$ readelf -d gif.Linux 

Dynamic section at offset 0x19cf640 contains 36 entries:
  Tag        Type                         Name/Value
 0x0000000000000001 (NEEDED)             Shared library: [libgfortran.so.5]
 0x0000000000000001 (NEEDED)             Shared library: [libsoundio.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libpulse.so.0]
 0x0000000000000001 (NEEDED)             Shared library: [libportaudio.so.2]
 0x0000000000000001 (NEEDED)             Shared library: [libasound.so.2]
 0x0000000000000001 (NEEDED)             Shared library: [libm.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [libmvec.so.1]
 0x0000000000000001 (NEEDED)             Shared library: [libpthread.so.0]
 0x0000000000000001 (NEEDED)             Shared library: [libc.so.6]
 0x0000000000000001 (NEEDED)             Shared library: [ld-linux-x86-64.so.2]
 0x000000000000001d (RUNPATH)            Library runpath: [.]

```


## Dependencies
TBC

## TODO
- 32-bit builds.
- Add a script that allows switching between Debug or Release mode.
- Do not bake the src into the repo - read it through a bind mount from the host.
- Choose static or dynamic linking.
- Other distros (especially at least one with stack protection!)
