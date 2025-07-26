#!/bin/bash

# Load average values
LA1=$(uptime | cut -d' ' -f 12- | awk -F", " '{print $1}')
LA5=$(uptime | cut -d' ' -f 12- | awk -F", " '{print $2}')
LA15=$(uptime | cut -d' ' -f 12- | awk -F", " '{print $3}')


count_core=$(nproc)
warning_threshold=$(echo "scale=2; $count_core * 0.7" | bc)
critical_threshold=$(echo "scale=2; $count_core * 1.5" | bc)

# Print system status message function
la_message() {
if [ "$(echo "$LA1 < $warning_threshold" | bc -l) " -eq 1 ]
then
    echo -e "\e[32mThe system works well\e[0m"
elif [ "$(echo "$LA1 >= $warning_threshold" | bc -l)" -eq 1  ] && [ "$(echo "$LA1 < $count_core" | bc -l)" -eq 1 ]
then
    echo -e "\e[33mCaution: the system is close to overloading\e[0m"
elif [ "$(echo "$LA1 >= $count_core" | bc -l)" -eq 1 ] && [ "$(echo "$LA1 < $critical_threshold" | bc -l)" -eq 1 ]
then
    echo -e "\e[33mWarning: all systems cores are loaded\e[0m"
else
    echo -e "\e[31mWARNING: The system is overloaded. Perform the following steps:\n\n    1. Look under 'Top-5 processes by CPU usage' below for the most loaded processes"
    echo "    2. Look at the PIDs of the processes in the 'PID' column and terminate the processes with the command 'sudo kill -15 <PID>'"
    echo -e "    3. Run the script again and check Load Average values\e[0m"
fi
}

#CPU usage in percentage
cpu_usage=$(top -bn1 | grep "\%Cpu(s):" | awk '{print 100 - $8}')

#Total memory used
total=$(free -m | awk '/Mem:/ {print $2}')
used=$(free -m | awk '/Mem:/ {print $3}')
freem=$(free -m | awk '/Mem:/ {print $4}')
memory_used=$(echo "scale=2; $used / $total * 100" | bc)
memory_free=$(echo "scale=2; $freem / $total * 100" | bc)

#Total disk usage
used_disk=$(df --block-size=G | grep -E "/$" | awk '{print $3}')
total_disk=$(df --block-size=G | grep -E "/$" | awk '{print $2}')
free_disk=$(df --block-size=G | grep -E "/$" | awk '{print $4}')
disk_used=$(echo "scale=2; $used_disk / $total_disk * 100" | bc)
disk_free=$(echo "scale=2; $free_disk / $total_disk * 100" | bc)

#Version OS
version=$(cat /etc/os-release | grep "VERSION=" | sed -n -e 's/VERSION=//' -e 's/"//g p')


echo -e "=====================Server-Performance-Stats=====================\n"

echo -e "Total CPU usage:  $cpu_usage%\n"
echo "-------------"

echo -e "\nLoad Average on the server:"
echo "	Last 1 minute: $LA1"
echo "	Last 5 minutes: $LA5"
echo -e "	Last 15 minutes: $LA15\n"

echo -e "The number of cores in the system: $count_core\n"
la_message
echo -e "\n-------------"

echo -e "\nTotal memory usage:"
echo "	Used memory: $used MB  / $total MB ($memory_used%)"
echo -e "	Free memory: $freem MB / $total MB ($memory_free%)\n"
echo "-------------"

echo -e "\nTotal disk usage:"
echo "	Used disk: $used_disk / $total_disk ($disk_used%)"
echo -e "	Free disk: $free_disk / $total_disk ($disk_free%)\n"
echo "-------------"

echo -e "\nTop-5 processes by CPU usage:\n"
top -bn 1 -o %CPU | grep -E "^ +" | head -n 6 | awk '{printf "%-10s %-15s %-10s %-5s\n", $1, $2, $9, $"12"}'
echo -e "\n-------------"

echo -e "\nTop-5 processes by memory usage:\n"
top -bn 1 -o %MEM | grep -E "^ +" | head -n 6 | awk '{printf "%-10s %-15s %-10s %-5s\n", $1, $2, $"10", $"12"}'
echo -e "\n-------------"

echo -e "\nVersion OS: $version"
echo "Uptime: $(uptime -p)"

echo -e "\n=====================Server-Performance-Stats====================="

