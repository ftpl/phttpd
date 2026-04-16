#!/data/data/com.termux/files/usr/bin/bash
# 2026.0415.1641
#
test1="測試壹\r\n測試壹\n\n"; # 9dbab0b921c6344e999f8051886f6ba0
test2="测试二\r\n测试二\r\r"; # 88f7026b72b440862dbcd10777fa5ab6
tfile1="/data/data/com.termux/files/home/phttpd-testfile1.bin";
tfile2="/data/data/com.termux/files/home/phttpd-testfile2.bin";
wwwroot="/data/data/com.termux/files/home/storage/shared/Download";
uplddir="${wwwroot}/ul";
workdir="${tfile1%/*}";
thost="http://127.0.0.1:58080";
tfile="${thost}/20260129_090259.m4a";
pfile="/storage/emulated/0/Download/20260129_090259.m4a";

oexec='dbgtext=1 dbgheader=1 dbgpayload=1 dbgbinary=0 wwwroot="'"${wwwroot}"'" phttpd.pl ';

dotest() {
 rm "${tfile1}";
 rm "${tfile2}";
 rm "${uplddir}/${tfile1##*/}";
 rm "${uplddir}/${tfile2##*/}";
cd "${workdir}";
echo -e "\ndir:";
curl -sSk "${thost}/"|grep -ie "^<tr>"

echo -ne "${test1}" > ${tfile1}
echo -ne "${test2}" > ${tfile2}

echo -e "\norig:";
echo -e "\e[32m"
md5sum -b "${tfile1}";
md5sum -b "${tfile2}";
echo -e "\e[0m"

echo "upld:"
curl -fsSk -X POST -F "phttpd=@${tfile1}" -F "phttpd=@${tfile2}" "${thost}/ul";
echo -e "\e[32m"
md5sum -b  "${uplddir}/${tfile1##*/}";
md5sum -b "${uplddir}/${tfile2##*/}";
echo -e "\e[0m"

echo "down:"
echo -e "\e[32m"
curl -fsSk "${thost}/ul/${tfile1##*/}"|md5sum -b
curl -fsSk "${thost}/ul/${tfile2##*/}"|md5sum -b
echo -e "\e[0m"

echo "down-large:"
echo -e "\e[32m"
echo "${tfile}"
curl -fsSk -o /dev/null "${tfile}"
echo "err.no: $?"
echo -e "\e[0m"

echo "uload-large:"
curl -fsSk -X POST -F "phttpd=@${pfile}" -F "phttpd=@${tfile1}" -F "phttpd=@${tfile2}" "${thost}/ul";
echo -e "\e[32m"
echo "${pfile}"
echo "err.no: $?"
md5sum -b "${pfile}"
md5sum -b  "${uplddir}/${pfile##*/}";
echo -e "\e[0m"

}

echo "is it running? :"
read -p "${oexec}  (y/n) [n] " choice
choice=${choice:-n}
case $choice in
    [Yy]) dotest ;;
    *) exit ;;
esac

