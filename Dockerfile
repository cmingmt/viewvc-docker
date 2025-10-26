# 使用 Ubuntu 18.04 (Bionic Beaver) 作为基础镜像
FROM ubuntu:18.04

# 设置 ViewVC 版本和安装路径
ENV VIEWVC_VERSION 1.2.5
ENV VIEWVC_HOME /usr/local/viewvc

# 安装必要的软件包：
# python: Ubuntu 18.04 下的 Python 2.7
# python-svn: Python 2 的 Subversion 绑定
# subversion/cvs: 仓库支持
# nginx/fcgiwrap: Web 服务器和 CGI 包装器
# build-essential: 编译工具
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        subversion \
        cvs \
		rcs \
		graphviz \
		cvsgraph \
        python \
        python-svn \
        python-pip \
        nginx \
        fcgiwrap \
        wget \
        tar \
		nano \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://www.viewvc.org/downloads/viewvc-${VIEWVC_VERSION}.tar.gz -O /tmp/viewvc.tar.gz \
    && tar xzf /tmp/viewvc.tar.gz -C /tmp \
    && cd /tmp/viewvc-${VIEWVC_VERSION} \
    && mkdir -p ${VIEWVC_HOME} \ 
	&& \
    echo  | python viewvc-install --prefix=${VIEWVC_HOME} \
    && rm -rf /tmp/viewvc* 
	
RUN mkdir -p /var/www/html/cgi-bin \ 
    && mkdir -p /var/www/html/viewvc \
    && mv /usr/local/viewvc/viewvc.conf /usr/local/viewvc/viewvc.conf.backup \
	&& cp /usr/local/viewvc/bin/cgi/viewvc.cgi  /var/www/html/cgi-bin/ \
	&& cp -r /usr/local/viewvc/templates/default/docroot /var/www/html/viewvc \
    &&  sed -Ei "s#(Powered by .+?<\/a>)#\1 in a $(cat /etc/issue | cut -d ' ' -f 1-2) based Docker container#"  ${VIEWVC_HOME}/templates/default/*/footer.ezt 

 
COPY nginx-viewvc.conf /etc/nginx/nginx.conf
COPY viewvc.conf /usr/local/viewvc/viewvc.conf
COPY cvsgraph.conf /usr/local/viewvc/cvsgraph.conf

EXPOSE 80

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
