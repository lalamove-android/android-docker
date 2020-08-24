FROM ubuntu:18.04
LABEL maintainer="Alan Wong <chapp.hkg@gmail.com>"

ENV VERSION_SDK_TOOLS "4333796"

ENV ANDROID_HOME "/sdk"
ENV ANDROID_SDK_ROOT $ANDROID_HOME
ENV PATH "$PATH:${ANDROID_HOME}/tools"
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -qq update && \
    apt-get install -qqy --no-install-recommends \
        bzip2 \
        curl \
        wget \
        ssh \
        git-core \
        html2text \
        openjdk-8-jdk \
        libc6-i386 \
        lib32stdc++6 \
        lib32gcc1 \
        lib32ncurses5 \
        lib32z1 \
        unzip \
        libqt5widgets5 \
        libqt5svg5 \
        locales \
        build-essential \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

RUN rm -f /etc/ssl/certs/java/cacerts; \
    /var/lib/dpkg/info/ca-certificates-java.postinst configure

RUN curl -s https://dl.google.com/android/repository/sdk-tools-linux-${VERSION_SDK_TOOLS}.zip > /sdk.zip && \
    unzip /sdk.zip -d /sdk && \
    rm -v /sdk.zip

# Accept Android sdk license
RUN yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses

ADD packages.txt /sdk
RUN mkdir -p /root/.android && \
    touch /root/.android/repositories.cfg && \
    ${ANDROID_HOME}/tools/bin/sdkmanager --update 

RUN while read -r package; do PACKAGES="${PACKAGES}${package} "; done < /sdk/packages.txt && \
    ${ANDROID_HOME}/tools/bin/sdkmanager ${PACKAGES}


# Install rclone
RUN wget https://downloads.rclone.org/rclone-current-linux-amd64.zip
RUN unzip rclone-current-linux-amd64.zip
RUN cd rclone-*-linux-amd64 && \
    cp rclone /usr/bin/ && \
    chown root:root /usr/bin/rclone && \
    chmod 755 /usr/bin/rclone

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_current.x | bash -
RUN apt-get install -y nodejs

# Install Conventional Commit
RUN npm install -g conventional-changelog-cli
RUN npm install -g standard-changelog
RUN npm install -g @commitlint/cli @commitlint/config-conventional

# Cleanup
RUN apt-get update && apt-get upgrade -y && apt-get autoremove -y

