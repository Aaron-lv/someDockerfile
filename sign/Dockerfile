FROM node:lts-alpine3.12

LABEL AUTHOR="none" \
        VERSION=0.0.1

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        LANG=zh_CN.UTF-8 \
        SHELL=/bin/bash \
        PS1="\u@\h:\w \$ " \
        DEFAULT_LIST_FILE=crontab_list.sh \
        CUSTOM_LIST_MERGE_TYPE=append

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache --virtual .build-deps g++ python3-dev libffi-dev openssl-dev make \
        && apk add --no-cache bash tzdata git moreutils curl jq python3 py3-pip \
        && rm -rf /var/cache/apk/* \
        && touch /root/.bashrc \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone \
        && git config --global pull.rebase true

RUN mkdir /jds \
        && cd /jds \
        && git init \
        && git remote add origin https://github.com/Aaron-lv/someDockerfile \
        && git config core.sparsecheckout true \
        && echo sign >> /jds/.git/info/sparse-checkout \
        && git pull origin master \
        && cd /jds/sign \
        && pip3 install --no-cache-dir --upgrade pip \
        && pip3 install --no-cache-dir --upgrade wheel \
        && pip3 install --no-cache-dir -r requirements.txt \
        && apk del .build-deps

RUN mkdir /scripts \ 
        && mkdir /logs \
        && npm install -g pnpm \
        && pnpm install -g pm2 \
        && rm -rf /root/.npm \
        && rm -rf /root/.pnpm-store

RUN cp /jds/sign/docker_entrypoint.sh /usr/local/bin \
        && chmod +x /usr/local/bin/docker_entrypoint.sh \
        && rm /usr/local/bin/docker-entrypoint.sh

WORKDIR /scripts

ENTRYPOINT ["docker_entrypoint.sh"]

CMD ["crond"]
