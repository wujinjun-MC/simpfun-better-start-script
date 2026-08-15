#!/bin/bash
#--------配置区--------
# 清除BlueMap地图缓存
export cleanBlueMap=0
# 清除DHSupport LOD 缓存
export cleanDistantHorizonsSupport=0
# 清除paper重映射插件缓存
export cleanPaperRemappedPlugins=0

#--------执行区--------
# 清除BlueMap地图缓存
if [ "$cleanBlueMap"x = "1"x ]
then
    echo "正在清除BlueMap地图缓存"
    rm -rf ~/bluemap/web/maps/*
fi
# 清除DHSupport LOD 缓存
if [ "$cleanDistantHorizonsSupport"x = "1"x ]
then
    echo "正在清除DHSupport LOD 缓存"
    rm -f ~/plugins/DHSupport/data.sqlite
fi
# 清除paper重映射插件缓存
if [ "$cleanPaperRemappedPlugins"x = "1"x ]
then
    echo "正在清除paper重映射插件缓存"
    rm -rf ~/plugins/.paper-remapped/*
fi
