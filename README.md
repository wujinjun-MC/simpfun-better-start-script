# 更好的简幻欢启动脚本(Minecraft服务器)

魔改简幻欢的start.sh，添加SSH功能，直接连接到Minecraft控制台

拆分出start-part-mcserver.sh用于启动Minecraft服务器，加入优化JVM参数、自动重启、防止Ctrl-C停止
