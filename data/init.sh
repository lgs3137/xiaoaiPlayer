#!/bin/sh

# 授权
chmod 755 /data/root/fm/*

# 持久化root目录
mount --bind /data/root /root

if [ -f /data/root/.ssh/authorized_keys ]; then
	# 把你PC的公钥添加到authorized_keys
	mount --bind /data/root/.ssh/authorized_keys /etc/dropbear/authorized_keys
fi

# 可选禁用password登录SSH，只允许使用私钥登录，开启前必须把你PC的公钥添加到authorized_keys，否则SSH无法登录只能长按禁麦恢复出厂
# mount --bind /data/root/.ssh/dropbear /etc/config/dropbear

# 重启SSH服务
/etc/init.d/dropbear restart

# 开启FM控制台
/data/root/fm/fm.sh start -auth AreYouOK
