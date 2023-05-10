```
# phttpd
pure perl static httpd / perl http web server
简单的perl单文件版静态httpd
现成的轮子一般都会引用外部模块，如果不具备安装模块的现实条件，这些脚本在丐版perl里运行的时候就会报错。
所以我引用了最少的模块来确保可用性，总之就是能用就行。
仅支持get方法和post上传(http://host:port/ul)
支持autoindex自动索引文件列表(如: http://host:port/ul/)
支持自定义正则来过滤修改指定的html文件内容后再输出，比如修改页面js代码或插入链接的js/css等。
(如果你用 wget -r 克隆网站，又不想手动修改成千上万个html中的特定内容，可通过修改lazyfix中的命令来实现你的需求)

my $addr = '0.0.0.0'; # 服务器的IP地址, 绑定到 'localhost' 则只允许本机访问
my $port = 58080; # 服务器监听的本地端口号
my $wwwroot = '.'; # 服务器根目录, '.'表示根目录为当前$(pwd)或%CD%文件夹
my $uploadurl = "/ul"; # 上传文件夹的web路径, 客户端请求此url时返回一个上传页面
my $uploadpath = $wwwroot . $uploadurl; # 上传文件夹在文件系统中的路径, 比如: /tmp/upload
my $fixmode = 1; # 页面修复模式总开关, 决定是否修改内容后再输出
my $indexmode = 1; # 是否自动索引文件列表

使用方法:
cd /wwwroot
perl phttpd.pl
```
