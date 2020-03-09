#!/system/bin/sh

rm -rf /sdcard/meminfo
mkdir /sdcard/meminfo
mkdir /sdcard/meminfo/meminfo
log_path="/sdcard/meminfo/meminfo"

getprop | tee /sdcard/meminfo/prop.txt
cat /sdcard/meminfo/prop.txt | grep "ro.product.device" | tee -a /sdcard/meminfo/deviceinfo.txt
cat /sdcard/meminfo/prop.txt | grep "ro.build.display.id" | tee -a /sdcard/meminfo/deviceinfo.txt
cat /sdcard/meminfo/prop.txt | grep "ro.build.version.release" | tee -a /sdcard/meminfo/deviceinfo.txt
cat /sdcard/meminfo/prop.txt | grep "ro.board.platform" | tee -a /sdcard/meminfo/deviceinfo.txt
cat /sdcard/meminfo/prop.txt | grep "ro.os_product.version" | tee -a /sdcard/meminfo/deviceinfo.txt
wm size | tee -a /sdcard/meminfo/deviceinfo.txt
cat /proc/version | awk '{print "kernel_version: " $3} ' | tee -a /sdcard/meminfo/deviceinfo.txt
cat /proc/meminfo | grep "MemTotal" | tee -a /sdcard/meminfo/deviceinfo.txt

#echo "dump_memory_parameter" | tee -a /sdcard/meminfo/deviceinfo.txt
cd /proc/sys/vm/
ls | awk '{print $0 ":" ;cmd="cat "$0; system(cmd);}' | tee -a /sdcard/meminfo/memory_para.txt

cat /proc/mtk_memcfg/reserve_memory | tee /sdcard/meminfo/reserve_memory.txt
cd /sys/module/lowmemorykiller/parameters
echo "adj" | tee -a /sdcard/meminfo/memory_para.txt
cat adj | tee -a /sdcard/meminfo/memory_para.txt
echo "minfree" | tee -a /sdcard/meminfo/memory_para.txt
cat minfree | tee -a /sdcard/meminfo/memory_para.txt

count=0
while (true)
do
time=`date '+%Y_%m%d_%H%M%S_%N'`
dumpsys -t 60 meminfo        | tee -a $log_path/dumpsys_meminfo_$time.txt
cat /proc/meminfo            | tee -a $log_path/dumpsys_meminfo_$time.txt
cat /proc/vmallocinfo | grep vmalloc | awk '{sum = sum + $2} END {print "vmalloc:", sum/1024}' | tee -a $log_path/dumpsys_meminfo_$time.txt
cat /d/ion/ion_mm_heap | grep "  total orphaned" | tee -a $log_path/dumpsys_meminfo_$time.txt
cat /d/ion/ion_mm_heap | grep "          total"  | tee -a $log_path/dumpsys_meminfo_$time.txt
echo "------------------------------------"
count=$(($count+1))
echo "cout: " $count
sleep 1
done
