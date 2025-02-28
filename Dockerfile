FROM alpine:latest

# 安装必要的包
RUN apk add --no-cache supervisor curl

# 安装sing-box
RUN wget https://github.com/SagerNet/sing-box/releases/download/v1.8.0/sing-box-1.8.0-linux-amd64.tar.gz && \
    tar -xzf sing-box-1.8.0-linux-amd64.tar.gz && \
    mv sing-box-*/sing-box /usr/local/bin/ && \
    rm -rf sing-box-*

# 安装mosdns
RUN wget https://github.com/IrineSistiana/mosdns/releases/download/v5.3.1/mosdns-linux-amd64.zip && \
    unzip mosdns-linux-amd64.zip && \
    mv mosdns /usr/local/bin/ && \
    rm mosdns-linux-amd64.zip

# 创建配置目录
RUN mkdir -p /etc/sing-box /etc/mosdns

# 复制配置文件
COPY ./sing-box/config.json /etc/sing-box/
COPY ./mosdns/config.yaml /etc/mosdns/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 暴露端口
EXPOSE 53/udp 53/tcp 1080/tcp

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]