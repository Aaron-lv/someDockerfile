FROM alpine
LABEL AUTHOR="none" \
        VERSION=0.1.5

ENV DEFAULT_LIST_FILE=crontab_list.sh \
        CUSTOM_LIST_MERGE_TYPE=append \
        COOKIES_LIST=/scripts/logs/cookies.list \
        REPO_URL=https://github.com/Aaron-lv/sync \
        REPO_BRANCH=jd_scripts

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache tzdata git nodejs moreutils npm curl jq python3 py3-pip py3-cryptography py3-numpy py-pillow \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone \
        && git config --global url."https://pd.zwc365.com/seturl/https://github.com/".insteadOf "https://github.com/"

RUN git clone -b $REPO_BRANCH $REPO_URL /scripts \
        && cd /scripts \
        && mkdir logs \
        && npm install

RUN mkdir /jds \
        && cd /jds \
        && git init \
        && git remote add origin https://github.com/Aaron-lv/someDockerfile \
        && git config core.sparsecheckout true \
        && echo jd_scripts >> /jds/.git/info/sparse-checkout \
        && git pull origin master --rebase

RUN cp /jds/jd_scripts/docker_entrypoint.sh /usr/local/bin \
        && chmod +x /usr/local/bin/docker_entrypoint.sh

WORKDIR /scripts

ENTRYPOINT ["docker_entrypoint.sh"]

CMD [ "crond" ]
