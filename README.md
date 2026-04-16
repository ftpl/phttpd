```
# phttpd.pl
pure perl static httpd / perl http web server
单文件perl脚本静态httpd,支持自动索引文件及上传.
上传url默认 http://[::]:$port/ul
流式切片解析上传文件和发送下载数据,防止内存耗尽.

支持自定义正则来过滤修改指定的html文件内容后再输出，比如修改页面js代码或插入链接的js/css等。
(如果你用 wget -r 克隆网站，又不想手动修改成千上万个html中的特定内容，可通过修改lazyfix函数来实现你的需求)

使用方法:
~$ perl phttpd.pl
或
~$ forceinet=0 fixmode=0 indexmode=1 dbgtext=0 dbgheader=1 dbgpayload=0 dbgbinary=0 wwwroot="~/storage/shared/Download" phttpd.pl 127.0.0.1:65535
```
