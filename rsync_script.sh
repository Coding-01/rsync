#!/bin/bash
#
#
k=`echo $$`
get_char()
{
  SAVEDSTTY=`stty -g`
  stty -echo
  stty raw
  dd if=/dev/tty bs=1 count=1 2> /dev/null
  stty -raw
  stty echo
  stty $SAVEDSTTY
}
echo -e "\033[31m在执行完该脚本后双向同步环境将搭建完成,但是后期还需要做点设置
比如服务端需要监控哪个目录、监控的权限等(create,delete,move...)
比如客户端需要指定服务端过来的数据同步到哪个目录,权限等(create,delete,modify...)
需修改双边主机名并在双边/etc/hosts中添加对应关系...
一切完成完后需手动reboot使主机名生效\033[0m"
echo -e "\n\n如上所述意思已明白,按任意键继续(q退出)...\n\n"
char=`get_char`
if [ $char == 'q' ];then
    kill -9 $k > /dev/null 2>&1
    exit
else
    $get_char
fi

if [ ! -d /opop ];then
    mkdir /opop
    cd /opop
fi
yum -y install gcc*
wget https://caml.inria.fr/pub/distrib/ocaml-3.10/ocaml-3.10.2.tar.gz  http://jaist.dl.sourceforge.net/project/inotify-tools/inotify-tools/3.13/inotify-tools-3.13.tar.gz  http://down1.chinaunix.net/distfiles/unison-2.27.57.tar.gz
for i in `ls *.gz`
do 
    tar -zxvf $i
done
cd ocaml-3.10.2
echo -e "\n\n\033[31mOcaml install,please waiting...\033[0m"
sleep 5
./configure && make world opt && make install
if [ $? != 0 ];then
    echo -e "\n\n\033[31mOcaml编译时出了点问题,请检查环境...\033[0m"
    kill -9 $k
    exit 
fi
cd ../unison-2.27.57
echo -e "\n\n\033[31mUnison install,please waiting...\033[0m\n\n"
sleep 5
yum -y install ctags-etags 
if [ ! -d "/root/bin" ];then
    mkdir /root/bin
fi
make UISTYLE=text  THREADS=true  STATIC=true
cp unison /root/bin/
cp unison /root/bin/unison-2.27
make UISTYLE=text  THREADS=true  STATIC=true
if [ $? != 0 ];then
    echo -e "\n\n\033[31mUnsion编译时出了点问题,请检查环境...\033[0m"
    kill -9 $k
    exit
fi
make install
ln -s /root/bin/unison /usr/local/bin/
echo -e "\n\n\033[31mInotify install,please waiting...\033[0m"
sleep 5
cd ../inotify-tools-3.13
./configure  && make && make install
if [ $? != 0 ];then
    echo -e "\n\n\033[31Minotify编译时出了点问题,请检查环境...\033[0m"
    kill -9 $k
    exit
fi
