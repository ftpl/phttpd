```
# phttpd
pure perl static httpd
简单的perl单文件版静态httpd
仅支持get和post上传(http://host:port/ul)
支持autoindex自动索引文件列表
支持自定义正则来过滤修改指定的html文件内容后再输出
(如果你有wget -r克隆的网站，又不想手动修改成千上万个html中的特定内容，可通过修改lazyfix中的命令来实现你的需求)

my $port = 58080; # 指定监听的端口号
my $document_root = '.'; # 指定静态文件的根目录，不修改的话默认为当前shell打开的位置$(pwd)
my $uploaddir = "/ul"; # 上传文件夹相对于 $document_root 的路径, 客户端请求此url时返回上传页面
my $uploadpath = $document_root . $uploaddir;  # 上传文件夹在文件系统中的路径，可修改成你需要的绝对跑径
my $fixmode = 1; # 是否启用页面修复模式, 修改内容后再输出
my $indexmode = 1; # 是否自动索引文件列表

使用方法:
cd /wwwroot
perl phttpd.pl
```
