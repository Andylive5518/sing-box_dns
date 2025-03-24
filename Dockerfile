FROM alpine:latest

# 安装必要的包
RUN apk add --no-cache supervisor curl wget unzip ipset iptables ip6tables

# 安装sing-box
RUN wget https://github.com/SagerNet/sing-box/releases/download/v1.11.4/sing-box-1.11.4-linux-amd64.tar.gz && \
    tar -xzf sing-box-1.11.4-linux-amd64.tar.gz && \
    mv sing-box-*/sing-box /usr/local/bin/ && \
    rm -rf sing-box-*

# 安装mosdns
RUN wget https://github.com/IrineSistiana/mosdns/releases/download/v5.3.3/mosdns-linux-amd64.zip && \
    unzip mosdns-linux-amd64.zip && \
    mv mosdns /usr/local/bin/ && \
    rm mosdns-linux-amd64.zip

# 创建配置目录
RUN mkdir -p /etc/sing-box /etc/mosdns/rules

# 创建规则目录
RUN mkdir -p /etc/sing-box/rules

# 复制更新脚本
COPY update_rules.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/update_rules.sh

# 初始更新规则
RUN /usr/local/bin/update_rules.sh

# 复制配置文件
COPY ./sing-box/config.json /etc/sing-box/
COPY ./mosdns/config.yaml /etc/mosdns/
COPY ./mosdns/rules/ntp_domains.txt /etc/mosdns/rules/
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# 暴露端口
EXPOSE 53/udp 53/tcp 1080/tcp

# 添加启动脚本
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]