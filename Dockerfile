FROM python:3.7

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates\
        sudo \
        openssh-server \
        wget \
        libnotify4 \
        gnupg \
        libxkbfile1 \
        libsecret-1-0 \
        libgtk-3-0 \
        libxss1 \
        libnss3 \
        libx11-xcb-dev \
        libxtst6 \
        libasound2 \
        xauth \
        iputils-ping \
        python3-opengl \
        libgl1-mesa-dev \
        libglu1-mesa-dev \
        freeglut3-dev \
        mesa-utils \
        x11-apps \
    && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

### User settings ###
ARG NB_USER=user01
ENV NB_USER ${NB_USER}
# HOST_ID should be same as host's user id.
ARG HOST_UID
ENV NB_UID ${HOST_UID}

# Add user and set password. (ここではユーザーのパスワードは"password"とします)
RUN useradd -m -G sudo -s /bin/bash -u $NB_UID $NB_USER && \
    echo "${NB_USER}:password" | chpasswd

RUN echo "Defaults visiblepw"             >> /etc/sudoers
RUN echo "${NB_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
### End ###

### SSHでDockerにアクセスするための設定
ARG AUTHORIZED_KEYS
RUN ( echo "#!/bin/bash"; \
      echo "echo ${AUTHORIZED_KEYS} > /home/${NB_USER}/.ssh/authorized_keys"; \
      echo "chown -R ${NB_USER}:${NB_USER} /home/${NB_USER}"; \
      echo "chmod 600 /home/${NB_USER}/.ssh/authorized_keys"; \
      echo "service ssh start"; \
      echo "tail -f /dev/null"; ) > /home/${NB_USER}/entrypoint.sh && \
    chmod +x /home/${NB_USER}/entrypoint.sh && \
    sed -i.bak 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    echo "PermitUserEnvironment yes" >> /etc/ssh/sshd_config && \
    echo "X11UseLocalhost no" >> /etc/ssh/sshd_config && \
    mkdir /home/${NB_USER}/.ssh && chmod 700 /home/${NB_USER}/.ssh && \
    ( echo "Host *"; \
      echo "    StrictHostKeyChecking no"; \
      echo "    UserKnownHostsFile=/dev/null"; ) > /home/${NB_USER}/.ssh/config
# Disable annoying warning about sudo
RUN touch ~/.sudo_as_admin_successful

# ユーザーの切り替え
USER $NB_USER
ENV LANG=ja_JP.UTF-8

EXPOSE 22 8888

# SSHサーバーを起動
CMD ["sudo","bash","-c", "bash /home/user01/entrypoint.sh"]
