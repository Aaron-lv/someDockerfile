FROM node:lts-alpine3.12

LABEL AUTHOR="none" \
        VERSION=0.1.5

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
        LANG=zh_CN.UTF-8 \
        SHELL=/bin/bash \
        PS1="\u@\h:\w \$ " \
        DEFAULT_LIST_FILE=crontab_list.sh \
        CUSTOM_LIST_MERGE_TYPE=append \
        COOKIES_LIST=/scripts/logs/cookies.list \
        REPO_URL=https://github.com/Aaron-lv/sync \
        REPO_BRANCH=jd_scripts

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache bash tzdata git moreutils curl jq python3 py3-pip py3-cryptography py3-numpy py-pillow \
        && rm -rf /var/cache/apk/* \
        && touch /root/.bashrc \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone \
        && git config --global pull.rebase true

RUN git clone -b $REPO_BRANCH $REPO_URL /scripts \
        && cd /scripts \
        && mkdir logs \
        && npm install -g pnpm \
        && pnpm install -g pm2 \
        && rm -rf /root/.npm \
        && pnpm install --prod \
        && rm -rf /root/.pnpm-store

RUN mkdir /jds \
        && cd /jds \
        && git init \
        && git remote add origin https://github.com/Aaron-lv/someDockerfile \
        && git config core.sparsecheckout true \
        && echo jd_scripts >> /jds/.git/info/sparse-checkout \
        && git pull origin master \
        && chmod 777 /jds/jd_scripts/*

RUN cp /jds/jd_scripts/docker_entrypoint.sh /usr/local/bin \
        && chmod +x /usr/local/bin/docker_entrypoint.sh \
        && rm /usr/local/bin/docker-entrypoint.sh

WORKDIR /scripts

ENTRYPOINT ["docker_entrypoint.sh"]

CMD ["crond"]
