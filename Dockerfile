FROM alpine:3.5

# Environment Variables
ARG LIBVIPS_VERSION_MAJOR_MINOR=8.5
ARG LIBVIPS_VERSION_PATCH=6
ARG MOZJPEG_VERSION="v3.2"

# Install dependencies
RUN echo "http://dl-cdn.alpinelinux.org/alpine/v3.5/community" >> /etc/apk/repositories && \
    apk update && \
    apk upgrade && \
    apk add --update \
    zlib libxml2 libxslt glib libexif lcms2 fftw ca-certificates \
    giflib libpng libwebp orc tiff poppler-glib librsvg && \

    apk add --no-cache --virtual .build-dependencies autoconf automake build-base \
    git libtool nasm zlib-dev libxml2-dev libxslt-dev glib-dev \
    libexif-dev lcms2-dev fftw-dev giflib-dev libpng-dev libwebp-dev orc-dev tiff-dev \
    poppler-dev librsvg-dev wget && \

# Install mozjpeg
    cd /tmp && \
    git clone git://github.com/mozilla/mozjpeg.git && \
    cd /tmp/mozjpeg && \
    git checkout ${MOZJPEG_VERSION} && \
    autoreconf -fiv && ./configure --prefix=/usr && make install && \

# Install libvips
    wget -O- https://github.com/jcupitt/libvips/releases/download/v${LIBVIPS_VERSION_MAJOR_MINOR}.${LIBVIPS_VERSION_PATCH}/vips-${LIBVIPS_VERSION_MAJOR_MINOR}.${LIBVIPS_VERSION_PATCH}.tar.gz | tar xzC /tmp && \
    cd /tmp/vips-${LIBVIPS_VERSION_MAJOR_MINOR}.${LIBVIPS_VERSION_PATCH} && \
    ./configure --prefix=/usr \
                --without-python \
                --without-gsf \
                --enable-debug=no \
                --disable-dependency-tracking \
                --disable-static \
                --enable-silent-rules && \
    make -s install-strip && \
    cd $OLDPWD && \

# Cleanup
    rm -rf /tmp/vips-${LIBVIPS_VERSION_MAJOR_MINOR}.${LIBVIPS_VERSION_PATCH} && \
    rm -rf /tmp/mozjpeg && \
    apk del --purge .build-dependencies && \
    rm -rf /var/cache/apk/*

