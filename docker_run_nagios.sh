#!/usr/bin/env bash
docker run -it \
--name XXX-monitor2 \
-h XXX-monitor2 \
--privileged=true \
--cap-add SYS_PTRACE \
--restart=always \
-e TZ=Asia/Hong_Kong \
-v /data/nagios:/opt/nagios \
-d  \
-p 30001:80 \
-p 5666:5666 \
reg.lexisnexis.com.cn/lnc-devops/lnc-nagios4.4.0:v3.0 \
sh /opt/nagios/init.sh
