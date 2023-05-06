# phttpd
pure perl static httpd
简单的perl单文件版静态httpd
仅支持get和post上传(http://host:port/ul)
支持autoindex自动索引文件列表
支持自定义正则来过滤修改指定的html文件内容后再输出
(如果你有wget -r克隆的网站，又不想手动修改成千上万个html中的特定内容)

使用方法:
cd /wwwroot
perl phttpd.pl
