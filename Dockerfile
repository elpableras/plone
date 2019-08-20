FROM python:3.7-slim-stretch

ENV PIP=19.0.3 \
    ZC_BUILDOUT=2.13.1 \
    SETUPTOOLS=41.0.0 \
    WHEEL=0.33.1 \
    PLONE_MAJOR=5.2 \
    PLONE_VERSION=5.2 \
    PLONE_VERSION_RELEASE=5.2.0 \
    PLONE_MD5=211ff749422611db2e448dea639e1fba

ENV PLONE /plone
ENV DATA  /data

LABEL plone=$PLONE_VERSION \
    os="debian" \
    os.version="9" \
    name="Plone 5.2" \
    description="Plone image, based on Unified Installer" \
    maintainer="pablogo"

# switch to root user
USER 0

#RUN useradd --system -m -d ${PLONE} -U -u 500 ${PLONE_USER}
# && mkdir -p /plone/instance/ /data/filestorage /data/blobstorage

RUN set -x \
    && mkdir -p "${PLONE}/instance/" "${DATA}/filestorage" "${DATA}/blobstorage"

COPY buildout.cfg ${PLONE}/instance/

RUN buildDeps="dpkg-dev gcc libbz2-dev libc6-dev libffi-dev libjpeg62-turbo-dev libopenjp2-7-dev libpcre3-dev libssl-dev libtiff5-dev libxml2-dev libxslt1-dev wget zlib1g-dev" \
 && runDeps="bash vim gosu libjpeg62 libopenjp2-7 libtiff5 libxml2 libxslt1.1 lynx netcat poppler-utils rsync wv" \
 && apt-get update \
 && apt-get install -y --no-install-recommends $buildDeps \
 && wget -O Plone.tgz https://launchpad.net/plone/$PLONE_MAJOR/$PLONE_VERSION/+download/Plone-$PLONE_VERSION_RELEASE-UnifiedInstaller.tgz \
 && echo "$PLONE_MD5 Plone.tgz" | md5sum -c - \
 && tar -xzf Plone.tgz \
 && cp -rv ./Plone-$PLONE_VERSION_RELEASE-UnifiedInstaller/base_skeleton/* /plone/instance/ \
 && cp -v ./Plone-$PLONE_VERSION_RELEASE-UnifiedInstaller/buildout_templates/buildout.cfg /plone/instance/buildout-base.cfg \
 && pip install pip==$PIP setuptools==$SETUPTOOLS zc.buildout==$ZC_BUILDOUT wheel==$WHEEL \
 && cd "${PLONE}/instance" \
 && buildout \
 && ln -s "${DATA}/filestorage/" "${PLONE}/instance/var/filestorage" \
 && ln -s "${DATA}/blobstorage" "${PLONE}/instance/var/blobstorage" \
 && chown -R 1001:0 /plone /data \
 && rm -rf /Plone* \
 && apt-get purge -y --auto-remove $buildDeps \
 && apt-get install -y --no-install-recommends $runDeps \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf "${PLONE}/buildout-cache/downloads/*"

#VOLUME /tmp
#VOLUME ["${DATA}"]

RUN    chmod -R 777                       "${PLONE}" \
    && chmod -R 777                       "${DATA}"

COPY initialize.py entrypoint.sh /

EXPOSE 8080

WORKDIR ${PLONE}/instance

#HEALTHCHECK --interval=1m --timeout=5s --start-period=1m \
HEALTHCHECK --interval=1m --timeout=5s \
  CMD nc -z -w5 127.0.0.1 8080 || exit 1

# switch back to unpriviledged user
USER 1001

ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
