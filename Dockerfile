FROM ubuntu:18.04

RUN apt-get update

RUN apt-get install -y openssh-server
RUN mkdir /var/run/sshd

RUN echo 'root:marmara' |chpasswd

RUN sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

RUN mkdir /root/.ssh

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 22

CMD    ["/usr/sbin/sshd", "-D"]

ENV TZ=Asia/Istanbul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update
RUN apt-get upgrade -y

RUN apt-get install build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev unzip git python python-zmq zlib1g-dev wget curl bsdmainutils automake cmake clang ntp ntpdate nano -y

RUN git clone https://github.com/marmarachain/marmara ~/komodo --branch master --single-branch


RUN ~/komodo/zcutil/fetch-params.sh
RUN ~/komodo/zcutil/build.sh -j$(nproc)

RUN wget https://eu.bootstrap.dexstats.info/MCL-bootstrap.tar.gz

RUN mkdir -p ~/.komodo/MCL
RUN tar -xvf /MCL-bootstrap.tar.gz -C ~/.komodo/MCL
