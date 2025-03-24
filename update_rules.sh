#!/bin/bash
# 设置权限
chmod 644 mosdns/rules/*.txt

#!/bin/sh

# 创建目录
mkdir -p /etc/mosdns/rules
mkdir -p /etc/sing-box/rules

# 下载mosdns规则
echo "开始下载MosDNS规则..."

# 下载规则列表
wget -O /etc/mosdns/rules/geosite-cn.txt https://raw.githubusercontent.com/Andylive5518/update_rules/refs/heads/main/rules/mosdns/geosite-cn.txt
wget -O /etc/mosdns/rules/geosite-all@cn.txt https://raw.githubusercontent.com/Andylive5518/update_rules/refs/heads/main/rules/mosdns/geosite-all@cn.txt
wget -O /etc/mosdns/rules/geosite-all@!cn.txt https://raw.githubusercontent.com/Andylive5518/update_rules/refs/heads/main/rules/mosdns/geosite-all@!cn.txt
https://raw.githubusercontent.com/Andylive5518/update_rules/refs/heads/main/rules/mosdns/geosite-geolocation-!cn.txt
https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/direct-list.txt
https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/proxy-list.txt
https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/reject-list.txt
https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/china-list.txt
https://raw.githubusercontent.com/Loyalsoldier/v2ray-rules-dat/release/gfw.txt
https://raw.githubusercontent.com/TG-Twilight/AWAvenue-Ads-Rule/main/Filters/AWAvenue-Ads-Rule-Mosdns_v5.txt
https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-domains.txt
https://raw.githubusercontent.com/Cats-Team/AdRules/main/mosdns_adrules.txt
wget -O /etc/mosdns/rules/cn_all.txt https://raw.githubusercontent.com/Andylive5518/update_rules/refs/heads/main/rules/mosdns/cn_all.txt

# 下载 GeoIP 和 GeoSite 数据
wget -O /etc/mosdns/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat
wget -O /etc/mosdns/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat

echo "MosDNS规则下载完成!"

# 更新sing-box规则
wget -O /etc/sing-box/rules/geoip.db https://github.com/Andylive5518/update_rules/raw/refs/heads/main/rules/sing-box/geoip.db
wget -O /etc/sing-box/rules/geosite.db https://github.com/Andylive5518/update_rules/raw/refs/heads/main/rules/sing-box/geosite.db

# 初始化ipset规则
echo "配置ipset规则集..."
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
echo "规则更新完成!"

# 重启服务以应用新规则
supervisorctl restart mosdns
supervisorctl restart sing-box