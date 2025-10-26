# Viewvc version is 1.2.5.
```shell
 docker build -t viewvc .
```
```shell
 docker run -d --name viewvc -p 80:80 -v /path/host/cvsroot:/opt/cvs:ro viewvc
```
 visit http://your-domian/

 Enjoy it.
