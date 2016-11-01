FROM openjdk:8
MAINTAINER Derek den Haas <d.haas@directcode.com>

ENV CORDOVA_VERSION=6.4.0 \
    NODEJS_VERSION=7.0.0 \
    ANDROID_BUILD_TOOLS_VERSION=23.0.3

ENV ANDROID_SDK_URL="https://dl.google.com/android/android-sdk_r24.4.1-linux.tgz" \
    ANDROID_APIS="android-15,android-16,android-17,android-18,android-19,android-20,android-21,android-22,android-23,android-24" \
    ANT_HOME="/usr/share/ant" \
    MAVEN_HOME="/usr/share/maven" \
    GRADLE_HOME="/usr/share/gradle" \
    ANDROID_HOME="/opt/android-sdk-linux"

ENV PATH $PATH:/opt/node/bin:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/$ANDROID_BUILD_TOOLS_VERSION:$ANT_HOME/bin:$MAVEN_HOME/bin:$GRADLE_HOME/bin

# Do some base stuff
WORKDIR "/tmp"
RUN dpkg --add-architecture i386 && \
    apt-get -qq update && \
    apt-get -qq install -y curl ant gradle libncurses5:i386 libstdc++6:i386 zlib1g:i386

# Install Android SDK
WORKDIR "/tmp"
RUN curl -sL ${ANDROID_SDK_URL} | tar xz -C /opt && \
    echo y | android update sdk -a -u -t platform-tools,${ANDROID_APIS},build-tools-${ANDROID_BUILD_TOOLS_VERSION} && \
    chmod a+x -R $ANDROID_HOME && \
    chown -R root:root $ANDROID_HOME

# Install NodeJS
WORKDIR "/opt/node"
RUN apt-get install -y curl ca-certificates --no-install-recommends && \
    curl -sL https://nodejs.org/dist/v${NODEJS_VERSION}/node-v${NODEJS_VERSION}-linux-x64.tar.gz | tar xz --strip-components=1

# Install Cordova
WORKDIR "/tmp"
RUN apt-get install -y git --no-install-recommends && \
    npm i -g --unsafe-perm cordova@${CORDOVA_VERSION}

# Clean up
WORKDIR "/tmp"
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    apt-get autoremove -y && \
    apt-get clean