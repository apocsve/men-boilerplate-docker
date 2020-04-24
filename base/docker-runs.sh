#!/bin/bash
set -e

export GNUPGHOME="$(mktemp -d)"

main()
{
  info "Installing required applications" 1
  install_common_apps
  info "Downloading and Installing NodeJS" 1
  install_nodejs
  info "Creating LOG directories" 1
  create_log_dirs
  info "Finalizing the deployment" 1
  apt-get clean
  apt-get purge -y --auto-remove xz-utils gnupg gcc make autoconf libc-dev pkg-config
  rm -rf "${GNUPGHOME}" /usr/local/bin/wp.gpg /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
}

install_common_apps()
{
apt-get update && apt-get install -y --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    cron \
    curl \
    dirmngr \
    git \
    gnupg \
    mysql-client \
    nginx \
    nodejs  \
    software-properties-common \
    supervisor netcat \
    tar \
    unzip \
    vim \
    wget \
    xz-utils
}

install_nodejs()
{
    NODE_VERSION=12.16.2
    groupadd --gid 1000 node && useradd --uid 1000 --gid node --shell /bin/bash --create-home node
    ARCH=''
    dpkgArch="$(dpkg --print-architecture)"

    case "${dpkgArch##*-}" in
        amd64) ARCH='x64';;
        ppc64el) ARCH='ppc64le';;
        s390x) ARCH='s390x';;
        arm64) ARCH='arm64';;
        armhf) ARCH='armv7l';;
        i386) ARCH='x86';; \
        *) echo "unsupported architecture"; exit 1 ;;
    esac
    set -ex
    for key in \
        94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
        FD3A5288F042B6850C66B31F09FE44734EB7990E \
        71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
        DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
        C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
        B9AE9905FFD7803F25714661B63B535A4C206CA9 \
        77984A986EBC2AA786BC0F66B01FBB92821C587A \
        8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
        4ED778F539E3634C779C87C6D7062848A1AB005C \
        A48C2BEE680E841632CD4E44F07496B3EB3C1762 \
        B9E2F5981AA6E0CD28160D9FF13993A75599653C
    do
        gpg --batch --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "${key}" || \
        gpg --batch --keyserver hkp://ipv4.pool.sks-keyservers.net --recv-keys "${key}" || \
        gpg --batch --keyserver hkp://pgp.mit.edu:80 --recv-keys "${key}"
    done
    curl -fsSLO --compressed "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${ARCH}.tar.xz"
    curl -fsSLO --compressed "https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt.asc"
    gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc
    grep " node-v${NODE_VERSION}-linux-${ARCH}.tar.xz\$" SHASUMS256.txt | sha256sum -c -
    tar -xvJf "node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" -C /usr/local --strip-components=1 --no-same-owner
    rm -v "node-v${NODE_VERSION}-linux-${ARCH}.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt
    ln -sv /usr/local/bin/node /usr/local/bin/nodejs

##############################
# Update NPM and Install Grunt
##############################

    npm i -g npm \
        && npm i -g nodemon \
        && npm cache clean --force
}

create_log_dirs()
{
    mkdir -p /var/log/supervisord/
}

info()
{
    message="$1"
    blink=''
    [ -z "$2" ] || blink=';5'

    echo -e "\e[45;1${blink}m$message\e[0m"
}

main $*