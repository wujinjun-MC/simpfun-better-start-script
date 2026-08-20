#!/bin/bash
cd ~/plugins/
while true; do
    read -ep "plugin url: " plugin_url
    # 清除下载链接后的参数，避免文件名异常
    plugin_url="${plugin_url%%\?*}"
    curl -fSL -OJ --connect-timeout 10 --retry 3 "$plugin_url"
    sleep 1
done
