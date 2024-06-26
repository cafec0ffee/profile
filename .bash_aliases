alias la='ls -aF'
alias lf='ls -FA'
alias ll='ls -lAF'
alias lh='ls -lh'

alias c="clear"
alias n="ss -nlptu"
alias no="netstat -atunlp"
alias zl="zfs list"
alias zls="zfs list -t snap"
alias diskusage="df -Th"
alias folderusage="du -ch"
alias totalfolderusage="du -sh"
alias myip="dig +short myip.opendns.com @resolver1.opendns.com"
alias findtxt="grep -r $1 $2"

mkcd() { mkdir -p "$1" && cd "$_"; }
pscan() {
  ports=$(nmap -p- --min-rate=500 $1 | grep ^[0-9] | cut -d '/' -f 1 | tr '\n' ',' | sed s/,$//);
  echo $ports;  nmap -p$ports -A $1;
}

sstart() { systemctl start $1; }
sstop() { systemctl stop $1; }
srestart() { systemctl restart $1; }
sstatus() { systemctl status $1; }

# Docker aliases #
alias dls="docker ps -a --format '{{.Names}}'"
alias dps="docker ps"
alias dpsa="docker ps -a"
alias dvl="docker volume"
alias dim="docker images"
alias dexec="docker exec -it"
alias drm="docker rm"
alias drmf="docker rm -f"
alias drmi="docker rmi"
alias dlog="docker logs"
alias dprune="docker system prune"
alias diprune="docker image prune"

# Docker compose aliases #
alias dc="docker compose"
alias dclog="docker compose logs"

dalias()    { alias | grep 'docker' | sed "s/^\([^=]*\)=\(.*\)/\1 => \2/"| sed "s/['|\']//g" | sort; }
dsh()       { docker exec -it $1 /bin/sh; }
dbash()     { docker exec -it $1 /bin/bash; }
dstart()    { docker start $1; }
dstop()     { docker stop $1; }
dstat()     { docker stats $1; }
dstats()    { docker stats $(docker ps -q); }

dcbuild()   { docker compose -f $FILE build --no-cache; }
dcstart()   { docker compose -f $FILE up -d --force-recreate; }
dcstop()    { docker compose -f $FILE down; }
dcrestart() { docker compose -f $FILE restart; }
dcupdate()  { docker compose pull && docker compose up -d --remove-orphans && docker image prune -f; }

dcmenu(){
  G="\033[38;5;41m"; C="\033[0m"; printf "${G}0${C} build | ${G}1${C} start | ${G}2${C} stop | ${G}3${C} restart | ${G}4${C} update | -> "
}

dcrun(){
if [ "$2" ]; then FILE="$2"; else FILE=docker-compose.yml; fi;
if [ "$1" ]; then
  case "$1" in
    build) dcbuild;; start) dcstart;; stop) dcstop;; restart) dcrestart;; update) dcupdate;;
    *) echo "build | start | stop | restart | update";;
  esac
else
  dcmenu
  read n
  case $n in
    0) dcbuild;; 1) dcstart;; 2) dcstop;; 3) dcrestart;; 4) dcupdate;; *) break;;
  esac
fi;}
alias run="dcrun"

# Proxmox aliases #
vmkill() {
  VM_ID=`ps aux | grep "/usr/bin/kvm -id $1" | awk -F' ' 'NR==1{print $2}'`
  VM_NAME=`ps aux | grep "/usr/bin/kvm -id $1" | awk -F"-name " '{print $2}' | awk -F"," '{print $1}'`
  kill -9 ${VM_ID}
  echo vm id:${1} name:${VM_NAME} killed
}
ctkill() { lxc-stop -n $1 --kill; }
ctip() { lxc-info -n $1 | awk '{print $2}' | grep "192.168"; }

# Others #
install(){
  #localectl set-locale LANG=ru_RU.UTF-8;
  timedatectl set-timezone Asia/Yekaterinburg;
  mkdir -p ~/.config/{mc,nano} && chmod 700 ~/.config/{mc,nano};
  echo -e "[New Left Panel]\nlist_format=brief\n\n[New Right Panel]\nlist_format=brief" > ~/.config/mc/panels.ini;
  echo 'include "/usr/share/nano/*.nanorc"' > ~/.config/nano/nanorc;
  echo 'SELECTED_EDITOR="/bin/nano"' > ~/.selected_editor
  apt-get clean; apt-get update; apt-get full-upgrade -y; apt-get autoremove --purge -y; apt-get autoclean;
  apt-get install -y mc wget curl screen htop;
}

installdocker(){ wget -qO- https://get.docker.com/ | sh; systemctl --now enable docker; }

updatealiases(){ wget -qN https://raw.githubusercontent.com/cafec0ffee/profile/main/.bash_aliases -O ~/.bash_aliases && source $_; }

ramdisk() {
  get_mount=`mount | awk '{if ($1 == "RAMDISK") print$1}'`
  if [ $get_mount ]; then
    mount | grep RAMDISK
    printf "delete ramdisk? (y|n): "; read n;
    if [ $n == "y" ]; then umount /tmp/ramdisk; fi;
  else
    printf "enter ramdisk size in GB: "; read n;
    mkdir -p /tmp/ramdisk && chmod 777 $_ && mount -t tmpfs -o size="${n}G" RAMDISK $_
  fi;
}
