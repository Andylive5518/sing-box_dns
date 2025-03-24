#!/bin/sh

# 确保ipset规则存在
ipset create cn_ip_set hash:net family inet 2>/dev/null || ipset flush cn_ip_set
ipset create cn_ip_set6 hash:net family inet6 2>/dev/null || ipset flush cn_ip_set6
ipset create non_cn_ip_set hash:net family inet 2>/dev/null || ipset flush non_cn_ip_set
ipset create non_cn_ip_set6 hash:net family inet6 2>/dev/null || ipset flush non_cn_ip_set6

# 配置iptables规则
echo "配置iptables规则..."

# 清理已存在的规则
iptables -t nat -D PREROUTING -p tcp -m set --match-set non_cn_ip_set dst -j REDIRECT --to-port 1080 2>/dev/null
iptables -t nat -D OUTPUT -p tcp -m set --match-set non_cn_ip_set dst -j REDIRECT --to-port 1080 2>/dev/null
ip6tables -t nat -D PREROUTING -p tcp -m set --match-set non_cn_ip_set6 dst -j REDIRECT --to-port 1080 2>/dev/null
ip6tables -t nat -D OUTPUT -p tcp -m set --match-set non_cn_ip_set6 dst -j REDIRECT --to-port 1080 2>/dev/null

# 添加新规则 - 将非中国IP的流量转发到代理
iptables -t nat -A PREROUTING -p tcp -m set --match-set non_cn_ip_set dst -j REDIRECT --to-port 1080
iptables -t nat -A OUTPUT -p tcp -m set --match-set non_cn_ip_set dst -j REDIRECT --to-port 1080
ip6tables -t nat -A PREROUTING -p tcp -m set --match-set non_cn_ip_set6 dst -j REDIRECT --to-port 1080
ip6tables -t nat -A OUTPUT -p tcp -m set --match-set non_cn_ip_set6 dst -j REDIRECT --to-port 1080

echo "iptables规则配置完成!"

# 启动supervisord
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf 