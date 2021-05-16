FROM alpine
LABEL AUTHOR="none" \
        VERSION=0.0.3

ENV DEFAULT_LIST_FILE=crontab_list.sh \
        CUSTOM_LIST_MERGE_TYPE=append \
        REPO_URL=https://github.com/Aaron-lv/sync \
        REPO_BRANCH=updateTeam

RUN set -ex \
        && apk update && apk upgrade \
        && apk add --no-cache tzdata git nodejs moreutils npm curl jq openssh-client \
        && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
        && echo "Asia/Shanghai" > /etc/timezone \
        && git config --global url."git@git.zhlh6.cn:".insteadOf "git@github.com:" \
        && git config --global url."https://pd.zwc365.com/seturl/https://github.com/".insteadOf "https://github.com/" \
        && mkdir -p /root/.ssh \
        && touch /root/.ssh/id_rsa \
        && chmod 600 /root/.ssh/id_rsa \
        && ssh-keyscan git.zhlh6.cn > /root/.ssh/known_hosts

RUN git clone -b $REPO_BRANCH $REPO_URL /updateTeam_scripts \
        && mkdir /scripts \
        && cp /updateTeam_scripts/*.* /scripts \
        && cd /scripts \
        && mkdir logs \
        && npm install

RUN mkdir /jds \
        && cd /jds \
        && git init \
        && git remote add origin https://github.com/Aaron-lv/someDockerfile \
        && git config core.sparsecheckout true \
        && echo updateTeam >> /jds/.git/info/sparse-checkout \
        && git pull origin master --rebase

RUN cp /jds/updateTeam/docker_entrypoint.sh /usr/local/bin \
        && chmod +x /usr/local/bin/docker_entrypoint.sh

WORKDIR /scripts

ENTRYPOINT ["docker_entrypoint.sh"]

CMD [ "crond" ]
