FROM alpine
LABEL VERSION=0.0.1

ENV DEFAULT_LIST_FILE=crontab_list.sh \
        CUSTOM_LIST_MERGE_TYPE=append

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache tzdata git moreutils python3 py3-pip jq curl \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone \
        && git config --global url."https://pd.zwc365.com/https://github.com/".insteadOf "https://github.com/"

RUN mkdir /logs \
        && mkdir /telethon \
        && mkdir /pss \
        && cd /pss \
        && git init \
        && git remote add origin https://github.com/Aaron-lv/someDockerfile \
        && git config core.sparsecheckout true \
        && echo telethon >> /pss/.git/info/sparse-checkout \
        && git pull origin master --rebase \
        && cd /pss/telethon \
        && pip3 install --upgrade pip \
        && pip3 install -r requirements.txt

RUN cp /pss/telethon/docker_entrypoint.sh /usr/local/bin \
        && chmod +x /usr/local/bin/docker_entrypoint.sh

WORKDIR /telethon

ENTRYPOINT ["docker_entrypoint.sh"]

CMD [ "crond" ]
