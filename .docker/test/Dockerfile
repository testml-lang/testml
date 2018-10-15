FROM ubuntu:18.04

RUN true \
 && apt-get update \
 && apt-get install -y \
    build-essential \
    figlet \
    git \
    gnupg \
    locales \
    lsb-core \
    nodejs \
    python \
    python3 \
    wget \
 && sed -i -e 's/# \(en_US\.UTF-8 .*\)/\1/' /etc/locale.gen \
 && locale-gen \
 && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 379CE192D401AB61 \
 && echo "deb https://dl.bintray.com/nxadm/rakudo-pkg-debs $(lsb_release -cs) main" \
    	>> /etc/apt/sources.list.d/rakudo-pkg.list \
 && wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb \
 && dpkg -i erlang-solutions_1.0_all.deb \
 && apt-get update \
 && apt-get install -y \
    elixir \
    esl-erlang \
    rakudo-pkg \
 && true

ENV \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PATH="/opt/rakudo-pkg/bin:/opt/rakudo-pkg/share/perl6/site/bin:$PATH"
