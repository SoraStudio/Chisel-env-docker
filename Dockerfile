FROM scratch
ADD rootfs.tar.xz /

ENV DEBIAN_FRONTEND noninteractive
ENV ORB_PORT=10000
ENV TANGO_HOST=127.0.0.1:${ORB_PORT}

RUN mkdir /workshop
WORKDIR /workshop

RUN set -ex

RUN apt update
RUN apt install -y sudo
RUN apt install -y tango-common
RUN sudo apt install -y build-essential bison flex curl
RUN sudo apt install -y libgmp-dev libmpfr-dev libmpc-dev zlib1g-dev vim git default-jdk default-jre
# install sbt: https://www.scala-sbt.org/release/docs/Installing-sbt-on-Linux.html
RUN echo "deb https://dl.bintray.com/sbt/debian /" | sudo tee -a /etc/apt/sources.list.d/sbt.list
RUN curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | sudo apt-key add
RUN sudo apt update
RUN sudo apt install -y sbt
RUN sudo apt install -y texinfo gengetopt
RUN sudo apt install -y libexpat1-dev libusb-dev libncurses5-dev cmake
# deps for poky
RUN sudo apt install -y python3.6 patch diffstat texi2html texinfo subversion chrpath git wget
# deps for qemu
RUN sudo apt install -y libgtk-3-dev gettext
# deps for firemarshal
RUN sudo apt install -y python3-pip python3-dev rsync libguestfs-tools expat ctags
# install DTC
RUN sudo apt install -y device-tree-compiler

RUN export MAKEFLAGS=-j8

# install verilator
RUN git clone http://git.veripool.org/git/verilator
WORKDIR /workshop/verilator
RUN git checkout v4.034
RUN autoconf && ./configure && make -j$(nproc) && sudo make install
RUN cd ..

# install chipyard
WORKDIR /workshop
RUN git clone https://github.com/ucb-bar/chipyard.git
WORKDIR /workshop/chipyard
RUN ./scripts/init-submodules-no-riscv-tools.sh

# build toolchain
RUN ./scripts/build-toolchains.sh riscv-tools # for a normal risc-v toolchain
RUN cd ..

CMD ["bash"]
