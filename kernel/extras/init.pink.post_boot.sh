#!/system/bin/sh

target=`getprop ro.board.platform`
debuggable=`getprop ro.debuggable`

echo 2 > /sys/module/lpm_resources/enable_low_power/l2
soc_revision=`cat /sys/devices/soc0/revision`
if [ "$soc_revision" != "1.0" ]; then
         echo 1 > /sys/module/lpm_resources/enable_low_power/pxo
fi
product=`getprop ro.boot.device`
if [ "$product" == "falcon" ]; then
	if [ "$soc_revision" == "1.0" ]; then
		echo 1 > /sys/kernel/debug/clk/cxo_lpm_clk/enable
	fi
fi
echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu1/power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu2/power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu3/power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu2/standalone_power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu3/standalone_power_collapse/suspend_enabled
echo 1 > /sys/module/msm_pm/modes/cpu0/standalone_power_collapse/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu1/standalone_power_collapse/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu2/standalone_power_collapse/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu3/standalone_power_collapse/idle_enabled
echo 1 > /sys/module/msm_pm/modes/cpu0/power_collapse/idle_enabled
echo 1 > /sys/devices/system/cpu/cpu1/online
echo 1 > /sys/devices/system/cpu/cpu2/online
echo 1 > /sys/devices/system/cpu/cpu3/online
chmod 664 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
chown -h system /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
chown -h root.system /sys/devices/system/cpu/cpu1/online
chown -h root.system /sys/devices/system/cpu/cpu2/online
chown -h root.system /sys/devices/system/cpu/cpu3/online
chmod -h 664 /sys/devices/system/cpu/cpu1/online
chmod -h 664 /sys/devices/system/cpu/cpu2/online
chmod -h 664 /sys/devices/system/cpu/cpu3/online

echo "intelliactive" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

echo 1 > /sys/module/intelli_plug/parameters/intelli_plug_active

############################
# mount debugfs
#
mount -t debugfs nodev /sys/kernel/debug

############################
# Tweak UKSM
#
chown root system /sys/kernel/mm/uksm/cpu_governor
chown root system /sys/kernel/mm/uksm/run
chown root system /sys/kernel/mm/uksm/sleep_millisecs
chown root system /sys/kernel/mm/uksm/max_cpu_percentage
chmod 644 /sys/kernel/mm/uksm/cpu_governor
chmod 664 /sys/kernel/mm/uksm/sleep_millisecs
chmod 664 /sys/kernel/mm/uksm/run
chmod 644 /sys/kernel/mm/uksm/max_cpu_percentage
echo 1 > /sys/kernel/mm/uksm/run
echo 100 > /sys/kernel/mm/uksm/sleep_millisecs
echo medium > /sys/kernel/mm/uksm/cpu_governor
echo 25 > /sys/kernel/mm/uksm/max_cpu_percentage

############################
# Tweak ZSWAP
#
echo 70 > /proc/sys/vm/swappiness

############################
# Init VNSWAP
#
echo 402653184 > /sys/block/vnswap0/disksize
mkswap /dev/block/vnswap0
swapon /dev/block/vnswap0

############################
# pink tweaks
#
echo 8 > /proc/sys/vm/page-cluster
echo 1 > /proc/sys/kernel/multi_threading
echo 2 > /sys/devices/system/cpu/sched_mc_power_savings

############################
# Script to launch frandom at boot by Ryuinferno @ XDA
#
chmod 644 /dev/frandom
chmod 644 /dev/erandom
mv /dev/random /dev/random.ori
mv /dev/urandom /dev/urandom.ori
ln /dev/frandom /dev/random
chmod 644 /dev/random
ln /dev/erandom /dev/urandom
chmod 644 /dev/urandom

############################
#
# Lioux
# Thanks to Lisan Xda
# Enable FQ Codel
#
# active fq_codel on the most used interfaces
tc qdisc add dev p2p0 root fq_codel
tc qdisc add dev rmnet0 root fq_codel
tc qdisc add dev wlan0 root fq_codel
# reduce txqueuelen to 0 until we have byte queue instead of a packet one
echo 0 > /sys/class/net/p2p0/tx_queue_len
echo 0 > /sys/class/net/rmnet0/tx_queue_len
echo 0 > /sys/class/net/wlan0/tx_queue_len
# suitable configuration to help reduce network latency
echo 2 > /proc/sys/net/ipv4/tcp_ecn
echo 1 > /proc/sys/net/ipv4/tcp_sack
echo 1 > /proc/sys/net/ipv4/tcp_dsack
echo 1 > /proc/sys/net/ipv4/tcp_low_latency
echo 1 > /proc/sys/net/ipv4/tcp_timestamps
echo 1 > /proc/sys/net/ipv4/route/flush
echo 1 > /proc/sys/net/ipv4/tcp_rfc1337
echo 0 > /proc/sys/net/ipv4/ip_no_pmtu_disc
echo 1 > /proc/sys/net/ipv4/tcp_fack
echo 1 > /proc/sys/net/ipv4/tcp_window_scaling
echo "4096 39000 187000" > /proc/sys/net/ipv4/tcp_rmem
echo "4096 39000 187000" > /proc/sys/net/ipv4/tcp_wmem
echo "187000 187000 187000" > /proc/sys/net/ipv4/tcp_mem
echo 1 > /proc/sys/net/ipv4/tcp_no_metrics_save
echo 1 > /proc/sys/net/ipv4/tcp_moderate_rcvbuf

emmc_boot=`getprop ro.boot.emmc`
case "$emmc_boot"
    in "true")
        chown -h system /sys/devices/platform/rs300000a7.65536/force_sync
        chown -h system /sys/devices/platform/rs300000a7.65536/sync_sts
        chown -h system /sys/devices/platform/rs300100a7.65536/force_sync
        chown -h system /sys/devices/platform/rs300100a7.65536/sync_sts
    ;;
esac


