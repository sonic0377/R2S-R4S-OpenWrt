#!/bin/bash
clear

### 基础部分 ###
# 使用 O3 级别的优化
sed -i 's/Os/O3 -funsafe-math-optimizations -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections/g' include/target.mk
# 更新 Feeds
./scripts/feeds update -a
./scripts/feeds install -a

### 必要的 Patches ###
# BBRv2 kernel 5.15
#wget -qO ./target/linux/generic/hack-5.15/693-Add_BBRv2_congestion_control_for_Linux_TCP.patch https://gitlab.com/sirlucjan/kernel-patches/-/raw/master/5.15/bbr2-patches/0001-bbr2-5.15-introduce-BBRv2.patch 
#wget -qO - https://github.com/openwrt/openwrt/commit/7db9763.patch | patch -p1

### 获取额外的 LuCI 应用、主题 ###
# Miniupnpd
rm -rf feeds/luci/applications/luci-app-upnp
git clone -b main --depth 1 https://github.com/msylgj/luci-app-upnp.git feeds/luci/applications/luci-app-upnp
# MOD Argon
rm -rf feeds/luci/themes/luci-theme-argon
git clone -b randomPic --depth 1 https://github.com/msylgj/luci-theme-argon.git feeds/luci/themes/luci-theme-argon
# MOD TurboACC To Add BBRv2
# pushd feeds/luci/applications/luci-app-turboacc
# patch -p1 < ../../../../../PATCHES/002-mod-turboacc-switch-bbr-support-to-bbr2.patch
# popd
# DNSPod
git clone -b main --depth 1 https://github.com/msylgj/luci-app-tencentddns.git feeds/luci/applications/luci-app-tencentddns
ln -sf ../../../feeds/luci/applications/luci-app-tencentddns ./package/feeds/luci/luci-app-tencentddns
# OpenClash
rm -rf feeds/luci/applications/luci-app-openclash
svn co https://github.com/vernesong/OpenClash/branches/dev/luci-app-openclash feeds/luci/applications/luci-app-openclash
# ServerChan
rm -rf feeds/luci/applications/luci-app-serverchan
git clone -b master --depth 1 https://github.com/tty228/luci-app-serverchan.git feeds/luci/applications/luci-app-serverchan
# Mosdns
#svn export https://github.com/immortalwrt/packages/trunk/net/mosdns feeds/packages/net/mosdns
#ln -sf ../../../feeds/packages/net/mosdns ./package/feeds/packages/mosdns
#sed -i '/config.yaml/d' feeds/packages/net/mosdns/Makefile
#sed -i '/mosdns-init-openwrt/d' feeds/packages/net/mosdns/Makefile
#svn export https://github.com/QiuSimons/openwrt-mos/trunk/mosdns package/new/mosdns
svn export https://github.com/QiuSimons/openwrt-mos/trunk/luci-app-mosdns package/new/luci-app-mosdns
svn export https://github.com/QiuSimons/openwrt-mos/trunk/v2ray-geodata package/new/v2ray-geodata

### 最后的收尾工作 ###
# Lets Fuck
if [ ! -d "package/base-files/files/usr/bin" ]; then
    mkdir package/base-files/files/usr/bin
fi
cp -f ../SCRIPTS/fuck package/base-files/files/usr/bin/fuck
# 定制化配置
sed -i "s/'%D %V %C'/'Built by OPoA($(date +%Y.%m.%d))@%D %V'/g" package/base-files/files/etc/openwrt_release
sed -i "/DISTRIB_REVISION/d" package/base-files/files/etc/openwrt_release
sed -i "/%D/a\ Built by OPoA($(date +%Y.%m.%d))" package/base-files/files/etc/banner
sed -i "/openwrt_banner/d" package/emortal/default-settings/files/99-default-settings
sed -i "/80_upnp/d" package/emortal/default-settings/files/99-default-settings
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i 's/1608/1800/g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/10-cpufreq
sed -i 's/2016/2208/g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/10-cpufreq
sed -i 's/1512/1608/g' feeds/luci/applications/luci-app-cpufreq/root/etc/uci-defaults/10-cpufreq
# 生成默认配置及缓存
rm -rf .config

# 清理可能因patch存在的冲突文件
find ./ -name *.orig | xargs rm -rf
find ./ -name *.rej | xargs rm -rf

exit 0
