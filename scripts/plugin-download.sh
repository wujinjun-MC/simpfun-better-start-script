#!/bin/bash

# Tutorial: https://www.baeldung.com/linux/decoding-encoded-urls
# POSIX-compliant
URL_decode_posix_compliant() {
    strg="${*}"
    printf '%s' "${strg%%[%+]*}"
    j="${strg#"${strg%%[%+]*}"}"
    strg="${j#?}"
    case "${j}" in "%"* )
        printf '%b' "\\0$(printf '%o' "0x${strg%"${strg#??}"}")"
   	strg="${strg#??}"
        ;; "+"* ) printf ' '
        ;;    * ) return
    esac
    if [ -n "${strg}" ] ; then URL_decode_posix_compliant "${strg}"; fi
}

cd ~/plugins/
while true; do
    read -ep "plugin url: " plugin_url
    # cdn.modrinth.com: 清除下载链接后的参数，避免文件名异常
    if [[ "$plugin_url" = *"cdn.modrinth.com"* ]]; then
        plugin_url="${plugin_url%%\?*}"
    fi
    plugin_url_decode=$(URL_decode_posix_compliant "$plugin_url")
    echo "curl URL: $plugin_url_decode"
    curl -fSL -OJ --connect-timeout 10 --retry 3 "$plugin_url_decode"
    sleep 1
done
