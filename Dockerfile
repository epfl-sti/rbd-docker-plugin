FROM golang:1.4.2-wheezy

MAINTAINER Adam Avilla <aavilla@yp.com>


# Install Ceph.
ENV CEPH_VERSION hammer
RUN curl -sSL 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | \
    apt-key add -
RUN echo deb http://ceph.com/debian-${CEPH_VERSION}/ wheezy main | \
    tee /etc/apt/sources.list.d/ceph-${CEPH_VERSION}.list
RUN apt-get update && \
    apt-get install -y --force-yes \
        librados-dev \
        librbd-dev \
        ceph


ENV SRC_ROOT /go/src/github.com/yp-engineering/rbd-docker-plugin

# Setup our directory and give convenient path via ln.
RUN mkdir -p ${SRC_ROOT}
RUN ln -s ${SRC_ROOT} /rbd-docker-plugin
WORKDIR ${SRC_ROOT}

# Used to only go get if sources change.
ADD *.go ${SRC_ROOT}/
RUN go get -t .

# Add the rest of the files.
ADD . ${SRC_ROOT}

RUN mkdir /scripts
ADD scripts/* /scripts/

# Clean up all the apt stuff
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


CMD ["bash"]
