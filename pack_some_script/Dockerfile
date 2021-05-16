FROM alpine
LABEL VERSION=0.0.2

ENV DEFAULT_LIST_FILE=crontab_list.sh \
        CUSTOM_LIST_MERGE_TYPE=append

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache tzdata git nodejs moreutils npm python3-dev py3-pip py3-cryptography jq curl \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone \
        && git config --global url."https://pd.zwc365.com/seturl/https://github.com/".insteadOf "https://github.com/"

RUN mkdir /logs \
        && mkdir /pss \
        && cd /pss \
        && git init \
        && git remote add origin https://github.com/Aaron-lv/someDockerfile \
        && git config core.sparsecheckout true \
        && echo pack_some_script >> /pss/.git/info/sparse-checkout \
        && git pull origin master --rebase

RUN cp /pss/pack_some_script/docker_entrypoint.sh /usr/local/bin \
        && chmod +x /usr/local/bin/docker_entrypoint.sh

ENTRYPOINT ["docker_entrypoint.sh"]

CMD [ "crond" ]
