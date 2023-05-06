#!/bin/perl -W
# coding: utf-8
# 20230506.1906
# todo: PUT/POST.string
use strict;
use warnings;
use Socket;
use IO::Socket::INET;
use IO::Select;
#use Time::Piece;

my $srv = "Pure-Static-HTTPd";
my $port = 58080; # 指定监听的端口号
my $document_root = '.'; # 指定静态文件的根目录
my $uploaddir = "/ul"; # 上传文件夹相对于 $document_root 的路径, 客户端请求此url时返回上传页面
my $uploadpath = $document_root . $uploaddir;  # 上传文件夹在文件系统中的路径
my $fixmode = 1; # 页面修复模式, 修改内容后再输出
my $indexmode = 1; # 自动索引文件列表

my %codes = (
'200', 'OK',
'201', 'Created',
'202', 'Accepted',
'204', 'No Content',
'301', 'Moved Permanently',
'302', 'Moved Temporarily',
'304', 'Not Modified',
'400', 'Bad Request',
'401', 'Unauthorized',
'403', 'Forbidden',
'404', 'Not Found',
'500', 'Internal Server Error',
'501', 'Not Implemented',
'502', 'Bad Gateway',
'503', 'Service Unavailable',
);

# my %rc = rc('400',"test: Not supported method"); print $rc{'header'} . $rc{'html'};
sub rc ($$) { 
my ($code, $detail) = @_;
my $msg = "$code " . $codes{$code};
my $header = "HTTP/1.1 $msg\r\nContent-type: text/html\r\n\r\n";
my $html = "<!DOCTYPE html>\n<html>\n<HEAD>\n<TITLE>$msg</TITLE>\n";
$html .= "<META http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n</HEAD>\n";
$html .= "<body>\n<h1>$msg</h1>\n<h2><I>$srv</I> : \n$detail</h2>\n</body>\n</html>\n";
return ('header', $header, 'html', $html);
}

sub ti{
my $now = localtime;
#my $formatted_time = $now->strftime('%Y-%m-%d @ %H:%M:%S');
#print $formatted_time;
print $now;
}

# my @files=dir(.); my $str=join("\n", @files); print $str;
sub dir {
    my ($odir) = @_;
    opendir(my $odh, $odir) or die "Can't open directory $odir: $!";
    my @ofiles = readdir($odh);
    closedir($odh);
    @ofiles = sort { lc($a) cmp lc($b) } @ofiles;
    my @dresult; my @fresult;
    foreach my $ofile (@ofiles) {
        my $opath = "$odir/$ofile";
        my $osize = -d $opath ? '-' : -s $opath;
        my $omtime = -M $opath;
        my $odate = localtime((stat($opath))[9]);
        ##my $formatted_date = sprintf("%04d-%02d-%02d@%02d.%02d.%02d", $date->year+1900, $date->mon+1, $date->mday, $date->hour, $date->min, $date->sec);
        if (-d $opath){
        	push @dresult, sprintf("%-30s %10s %25s", '<a href="./' . "$ofile" . '/">' . "$ofile" . '/</a>', $osize, $odate);
        } else {
                push @fresult, sprintf("%-30s %10s %25s", '<a href="./' . "$ofile" . '">' . "$ofile" . '</a>', $osize, $odate);
        }
    }
    push @dresult, @fresult;
    return @dresult;
}

sub lazyfix {
my ($html) = @_;
$html =~ s/checktime\(\)\;/\/\/nochecktime\(\)\;/gi;
$html =~ s/window\._stat_params \= \{/delwindow\._stat_params \= \{/gi;
$html =~ s/https?\:\/\/\d+\.\d+\.\d+\.\d+\:\d+\//\//gi;
$html =~ s/\<\/head\>/\<script type=\"text\/javascript\" src=\"\/content\/js\/c.fix.menu.js\"\>\<\/script\>\n\<\/head\>/i;
$html =~ s/\<\/body\>/\<script type=\"text\/javascript\" src=\"\/content\/js\/c.fix.footer.js\"\>\<\/script\>\n\<\/body\>/i;
return $html;
}

sub p {
	my ($v) = @_;
	print $v;
}

# 创建监听套接字
my $server = IO::Socket::INET->new(
    LocalAddr => 'localhost',
    LocalPort => $port,
    Type      => SOCK_STREAM,
    Reuse     => 1,
    Listen    => 10,
) or die "Cannot create socket: $!";

my $select = IO::Select->new($server); # 创建 IO::Select 对象并添加监听套接字

ti(); print "\n$srv is running on port: $port\n";

while (1) {
    my @ready = $select->can_read; # 非阻塞地等待读取事件

    foreach my $fh (@ready) {
        if ($fh == $server) {
            # 监听套接字有新连接
            my $client = $server->accept();
            $select->add($client); # 添加新连接到 IO::Select 对象中
        } else {
            # 客户端套接字有数据可读
            my $client = $fh;
            my $client_address = $client->peerhost();
            my $client_port = $client->peerport();

            print "\nREQ from $client_address:$client_port\n";
			ti(); print "\n";
            # 读取 HTTP 请求头
            my $request = '';
            while (my $line = <$client>) {
                $request .= $line;
                last if $line =~ /^\r\n$/; # 请求头部结束标志
            }
			print "\n$request\n";
            # 解析请求行
            my ($method, $path) = split /\s+/, $request; if (!defined $path) { my $path=""; } else { p "\npath: $path\n"; }
            my ($rqurl, $search) = split /\?/, $path; if (!defined $search) { my $search=""; } else { p "\nsearch: $search\n"; }
		##my ($qname, $qval) = split /\=/, $search; if (!defined $qname) { my $qname=""; } if (!defined $qval) { my $qval=""; } else { p "\nqval: $qval\n"; }

			if ( $method eq 'PUT') {
			#* 处理 PUT 请求:
                # 发送 HTTP 501 响应
				my %resp = rc('501',"Not supported method: $method");
                print $client "$resp{'header'}$resp{'html'}\n";
				print "$resp{'header'}$resp{'html'}\n";
				print "******** test PUT ********\n";
			} elsif ( $method eq 'POST' ) {
			#* 处理 POST 请求:
			##print "\n\n========== \$request.start ==========\n$request\n========== \$request.end ==========\n\n";
				my ($boundary) = $request =~ /Content-Type:\s*multipart\/form-data;\s*boundary=(\S+)/i;
				##print "\n\n========== \$boundary: $boundary ==========\n";
				if ($boundary && $request =~ /Content-Length:\s*(\d+)/ ) {
					# 从请求体中解析出文件名和文件内容
					my $length = $1;
					my $read = 0;
					my $payload = '';
					while ($read < $length) {
						my $data = '';
						my $bytes = $client->read($data, $length - $read);
						last if $bytes == 0; # End of payload
						$payload .= $data;
						$read += $bytes;
					}
					##print "\n\n========== \$payload.start ==========\n$payload\n========== \$payload.end ==========\n\n";
					my ($filename) = $payload =~ /Content-Disposition:\s*form-data;\s*name=\"[^\"]+\";\s*filename=\"([^"]+)\"/i;
					##print "\n\n========== \$filename: $filename ==========\n";
					my ($content) = $payload =~ /$boundary[\r\n]+Content-Disposition:.*?filename=\"[^\"]+\"[\r\n]+Content-Type:.*?[\n\r]{4}(.*)[\r\n]--$boundary--/s;
					##print "\n\n========== \$content.start ==========\n$content\n========== \$content.end ==========\n\n";
					if ($filename && $content) {
						# 保存上传的文件
						my $filepath = $uploadpath . "/" . $filename;
						eval {
							open my $fh, '>', $filepath or die "Cannot open file '$filepath': $!";
							binmode $fh;
							print $fh $content;
							close $fh;
						};         
						if ($@) {
							# 发送 HTTP 500 响应
							my %resp = rc('500', "$@\n<br>Cannot save file to $filepath");
							print $client "$resp{'header'}$resp{'html'}\n";
							print "$resp{'header'}$resp{'html'}\n";
						} else {
							print "File '$filepath' uploaded successfully.\n";
							# 发送上传成功的响应
							my %resp = rc('200', "File uploaded: $filename\n");
							print $client "$resp{'header'}$resp{'html'}\n";
							print "$resp{'header'}$resp{'html'}\n";
						}
					} else {
						# 解析失败，发送 400 响应
						my %resp = rc('400',"err uploading file: $filename\n<br>Cannot analyze \$header or \$payload.");
						print $client "$resp{'header'}$resp{'html'}\n";
						print "$resp{'header'}$resp{'html'}\n";
					}
				}
			} elsif ( $method eq 'GET' ) {
			#* 处理 GET 请求:
				# 干掉用于伪动态传参的 url.location.search 字段, 防止报错找不到文件
				if ( $path =~ m/\?.*/ ) { $path =~ s/\?.*//g; }
				my $file = "$document_root$path";
				my $mime_type = 'text/html';
				if ($file =~ /\.js$/i) {
					$mime_type = 'text/javascript';
				} elsif ($file =~ /\.css$/i) {
					$mime_type = 'text/css';
				} elsif ($file =~ /\.(jpg|jpeg|bmp|png|gif|tiff?)$/i) {
					$mime_type = 'image/*';
				} elsif ($file =~ /\.(7z|rar|zip|tar|xz|gz|bz2?|bin|elf|so|exe|dll|pdf|xlsx?|pptx?|docx?|rtf|mp3|mp4|avi|aac|flac|wav|mkv|mpeg|ts|iso|ttf|fon|otf)$/i) {
					$mime_type = 'application/octet-stream';
				} elsif ($file =~ /\.(txt|csv|sh|bat|cmd|vbs|pl|py|log|reg|ini|cfg|md)$/i) {
					$mime_type = 'text/plain';
				}



				ti(); print "\nRESP to $client_address:$client_port\n\n";
				# 处理请求
				if( $path eq $uploaddir ) {
					# 创建上传页面
					my %resp = rc('200', '<br><br><form method="POST" action="' . $uploaddir . '" enctype="multipart/form-data" id="file"><input type="file" name="file"><input type="submit"></form>');
					print $client "$resp{'header'}$resp{'html'}\n";
					print "$resp{'header'}$resp{'html'}\n";
				} elsif (-e $file && -f $file) {
					# 生成文件内容
					open my $fh, '<', $file or die "Cannot open file: $!";
					my $cat="";
					while (my $line = <$fh>) {
						$cat .= "$line";
					}
					if ($fixmode == 1 && $mime_type eq 'text/html' && $path =~ /\@/ ) {
						$cat = lazyfix($cat);
						print "\n$cat\n";
					}
					# 生成 HTTP 响应头
					my $resp = "HTTP/1.1 200 OK\r\n";
					$resp .= "Content-Type: $mime_type\r\n\r\n";
					#$resp .= "Content-Length: " . length($cat) . "\r\n";
					print $client "$resp$cat";
					print "$resp";
					close $fh;
				} elsif (-e $file && -d $file) {
					if ($indexmode == 1) {
						my @files=dir($file); my $str=join("\n", @files);
						my %resp = rc('200', '<pre style="white-space: pre-wrap; white-space: -moz-pre-wrap; word-wrap: break-word;">' . "\n" . $str . "\n<\/pre>");
						print $client "$resp{'header'}$resp{'html'}\n";
						print "$resp{'header'}$resp{'html'}\n";
					} else {
					# 发送 HTTP 403 响应
						my %resp = rc('403', "auto index err.");
						print $client "$resp{'header'}$resp{'html'}\n";
						print "$resp{'header'}$resp{'html'}\n";
					}
				} else {
					# 发送 HTTP 404 响应
					my %resp = rc('404', "$file");
					print $client "$resp{'header'}$resp{'html'}\n";
					print "$resp{'header'}$resp{'html'}\n";
				} # GET 请求处理完毕
			} else {
			#* 处理未知请求:
                # 发送 HTTP 501 响应
				my %resp = rc('501',"Not supported method: $method");
                print $client "$resp{'header'}$resp{'html'}\n";
				print "$resp{'header'}$resp{'html'}\n";
				print "******** test method ********\n";
			}
            # 关闭客户端连接
            $select->remove($client); # 从 IO::Select 对象中移除客户端套接字
            close $client;
		}
	}
}

