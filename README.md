## 阿里云视频STS+VID点播和安全下载iOS客户端接入
```
本项目是用于演示如何在iOS 系统上使用阿里云的STS+VID视频点播和离线缓存并播放的Demo。
其中所使用到的第三方库以及服务器的代码，可以根据自己的业务需求酌情选择。
```

[官方帮助文档](https://help.aliyun.com/product/29932.html?spm=a2c4g.11186623.3.1.sbWrp9)

* [STS临时授权访问](https://help.aliyun.com/document_detail/57114.html?spm=a2c4g.11186623.6.594.rlmlLm)

* [安全下载](https://help.aliyun.com/document_detail/57030.html?spm=5176.11103239.955718.19.lUoNMd)

* [iOS客户端SDK](https://help.aliyun.com/document_detail/61668.html?spm=a2c4g.11186623.2.38.fKHxcx)

* [演示视频地址](http://v.youku.com/v_show/id_XMzU1NDM4OTkyMA==.html?firsttime=23)

## Demo工程
* 视频点播及下载的业务交互时序图

 ![image](https://github.com/PengHao/AliyunVideoPlayerDemo4STS-VID/blob/master/sequence.png?raw=true)


* 客户端业务模块流程图

 ![image](https://github.com/PengHao/AliyunVideoPlayerDemo4STS-VID/blob/master/flowchart.png?raw=true)



## 前期准备

#### 添加角色
1. 打开[访问控制台](https://ram.console.aliyun.com/?spm=5176.2020520001.1011.2.mJXobG#/overview)添加子账号，获取并记录accessToken和accessKey
2. 添加角色，获取角色名称
3. 设置权限

#### 上传视频
1. 打开[视频管理后台](https://vod.console.aliyun.com/?spm=5176.2020520001.aliyun_sidebar.7.SOq4Qu#/vod/mediaLibrary/video)，点击视频上传

#### 安全下载设置
1. 打开[安全下载](https://vod.console.aliyun.com/?spm=5176.2020520001.aliyun_sidebar.7.SOq4Qu#/vod/settings/download)
2. 勾选安全下载并填写客户端的bundleID和解密密钥
3. 点击生成密钥并下载

#### 域名管理
1. 打开[域名管理](https://vod.console.aliyun.com/?spm=5176.2020520001.aliyun_sidebar.7.SOq4Qu#/vod/settings/domain) 填写视频点播的域名。如果不填写可能会导致视频无法点播

## 操作步骤
#### 搭建Demo服务器
1. 安装JRE、IDEA 和 tomcat
2. 配置JAVA环境变量
3. 使用IDEA打开服务器工程，并配置本地tomcat启动
4. 替换子账号的AccessToken，AccessKey和角色名称
5. 本地启动工程

#### iOS客户端Demo
1. 安装XCode、cocoaspod
2. 命令行进入工程目录，执行pod install
3. 打开workspace工程
4. 修改budleId、服务器api地址为刚刚本地部署的地址
5. 替换安全下载的密钥文件
