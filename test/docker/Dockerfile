FROM ubuntu:18.04

# Runtime environment
RUN true \
 && apt-get update \
 && apt-get install -y \
        build-essential \
        figlet \
        git \
        gnupg \
        locales \
        lsb-core \
        wget \
 && sed -i -e 's/# \(en_US\.UTF-8 .*\)/\1/' /etc/locale.gen \
 && locale-gen \
 && true

ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# NodeJS / CoffeeScript / Perl 5 / Python 2 / Python 3
RUN true \
 && apt-get update \
 && apt-get install -y \
        nodejs \
        perl \
        python \
        python3 \
 && true

# Elixir
RUN true \
 && wget --quiet https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
 && dpkg -i erlang-solutions_1.0_all.deb \
 && apt-get update \
 && apt-get install -y \
    elixir \
    esl-erlang \
 && true

# Go
RUN true \
 && wget --quiet https://dl.google.com/go/go1.11.linux-amd64.tar.gz \
 && tar -xvf go1.11.linux-amd64.tar.gz \
 && mv go /usr/local/ \
 && true

ENV GOROOT=/usr/local/go \
    PATH="/usr/local/go/bin:$PATH"

# Perl 6
RUN true \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 379CE192D401AB61 \
 && echo "deb https://dl.bintray.com/nxadm/rakudo-pkg-debs $(lsb_release -cs) main" \
    	>> /etc/apt/sources.list.d/rakudo-pkg.list \
 && apt-get update \
 && apt-get install -y \
    rakudo-pkg \
 && true

ENV PATH="/opt/rakudo-pkg/bin:/opt/rakudo-pkg/share/perl6/site/bin:$PATH"
