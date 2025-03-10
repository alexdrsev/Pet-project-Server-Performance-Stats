#!bin/bash

#overall CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 -$8"%"}')

#Overall memory usage
free_menory=$(free -m | awk 'NR==2{printf "Free memory: %sMB", $4}')
used_memory=$(free -m | awk 'NR==2{printf "Used memory: %sMB", $3}')
mem_info_total=$(free -m | awk 'NR==2{printf "Used: %sMB / %sMB (%.2f%%)", $3, $2, $3*100/$2}')

#Overall disk usage
disk_free=$(df -h | awk 'NR==3{printf "Available: %s", $4}')
disk_usage=$(df -h | awk 'NR==3{printf "Used: %s", $3}')
disk_info=$(df -h | awk 'NR==3(printf "Overall: %s / %s (%s)", $3, $2, $5}')

#Top-5 processes by CPU
top_5_process_CPU=$(ps -Ao pid,cmd,%cpu --sort=-%cpu | grep -v "[p]s" | head -n6)

#Top-5 processes by using memory
top_5_memory_processes=$(ps -Ao pid,command,%mеm --sort=-%mem | grep -v "[p]s" | head -n6)

#System information
version_OS=$(cat /etc/os-release | grep "^PRETTY_NAME=" | cut -d"=" -f2)
uptime_info=$(uptime -p)
load_average=$(uptime | awk -F'load average: ' '{print $2}' | awk -F', ' '{print "    LA last 1 minute:", $1, "\n    LA last 5 minutes:", $2, "\n    LA last 15 minutes:",
$3}')


echo -e "===== Based Server Performance Statistics =====\n"

echo -e "CPU Usage: $cpu_usage\n"


echo -e "Overall memory usage:\n  $free_memory\n  $used_memory\n  $mem_info_total\n"

echo -e "Overall disk usage:\n  $disk_free\n  $disk_usage\n  $disk_info\n"

echo -e "Top-5 processes by CPU:\n $top_5_process_CPU\n"
echo -e "Top-5 processes by using memory:\n $top_5_memory_processes\n"

echo -e "System Information:\n  Version OS: $version_OS\n  Uptime: $uptime_info\n  Load average:\n$load_average"