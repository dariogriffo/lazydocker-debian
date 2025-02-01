ARG DEBIAN_DIST=bookworm
FROM debian:$DEBIAN_DIST

ARG DEBIAN_DIST
ARG LAZYDOCKER_VERSION
ARG BUILD_VERSION
ARG FULL_VERSION

RUN apt update && apt install -y wget
RUN mkdir -p /output/usr/bin
RUN mkdir -p /output/usr/share/doc/lazydocker
RUN cd /output/usr/bin && wget https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz && tar -xf lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz && rm -f lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz && rm -fRd LICENSE README.md 
RUN mkdir -p /output/DEBIAN

COPY output/DEBIAN/control /output/DEBIAN/
COPY output/copyright /output/usr/share/doc/lazydocker/
COPY output/changelog.Debian /output/usr/share/doc/lazydocker/
COPY output/README.md /output/usr/share/doc/lazydocker/

RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/usr/share/doc/lazydocker/changelog.Debian
RUN sed -i "s/FULL_VERSION/$FULL_VERSION/" /output/usr/share/doc/lazydocker/changelog.Debian
RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/DEBIAN/control
RUN sed -i "s/LAZYDOCKER_VERSION/$LAZYDOCKER_VERSION/" /output/DEBIAN/control
RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/DEBIAN/control

RUN dpkg-deb --build /output /lazydocker_${FULL_VERSION}.deb


