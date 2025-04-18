# Electron-Api-Demo

Electron Api Demo是一个开源项目，它基于vite + vue3技术栈，将向您展示如何将Electron-RTCSDK集成到您的项目中的不同场景。

## 🚀 快速开始

### 环境要求

- [Node.js](https://nodejs.org/en/download/) 大于>=14

### 创建账号

1. 您需要在云屋[SDK官网](https://sdk.cloudroom.com/)注册账号并创建项目，具体流程参见[准备工作](https://docs.cloudroom.com/sdk/document/fastIntegration/beforeDevelop?platform=Electron)
1. 项目创建完成，获取到`AppId`和`AppSecret`，选择以下之一方式：
    - 在`electron/main/auth.ts`文件中修改对应的值
    - 启动项目后，在设置界面中填入对应的值

### 步骤

```bash
git clone git@github.com:cloudroomSDK/API-Demo.git
cd API-Demo/Electron
npm install
npm run dev
```

## 📖 演示场景

- **基本演示:**

| 流程 | 描述  | 
|----- | -------- | 
| 项目开发及构建 | 项目一键启动及构建 |
| 初始化 | 日志、视频等功能的配置  |
| 登录和注销 | 登录是SDK的必要流程，使用前必须登录  |
| 创建、进入和退出房间 | 同一个房间内的用户可相互观看视频  |

- **高级演示:**

| 模块 | 体验功能  | 
|----- | -------- | 
| 音频设置 | 麦克风、扬声器切换，音量大小调节 |
| 视频设置 | 摄像头切换，分辨率、码率等调节  |
| 本地录制 | 本地录制房间内的视频画面，文件存储在本地  |
| 云端录制 | 服务端录制房间内的视频画面，文件存储在云端   |
| 屏幕共享 | 可共享自己的屏幕或者观看他人的屏幕  |
| 影音共享 | 可共享自己的媒体文件或者观看他人正在共享的媒体  |
| 房间消息 | 房间内的IM消息通道  |
| 房间属性 | 房间的属性增删改查  |
| 用户属性 | 成员的属性增删改查  |
| 虚拟摄像头 | 支持rtmp/rtsp等IP摄像头、桌面、自定义摄像头  |
| 变声 | 调节自己或他人的变声 |
| 声音环回测试 | 服务端将自己的声音回传，用于麦克风测试  |

## Windows 7/8/8.1下无法运行
如果您需要兼容这些系统，可以自行降低Electron应用版本至22或以下。原因是Chromium内核从110版本之后不再兼容这些系统,详情[参见这里](https://www.electronjs.org/zh/blog/windows-7-to-8-1-deprecation-notice)。

## 🔖 附录

- [开发者文档](https://docs.cloudroom.com/sdk/document/intro/README?platform=Electron)
- [其他平台SDK下载](https://sdk.cloudroom.com/pages/download#sdk)
- [API Demo](https://github.com/cloudroomSDK/API-Demo)
- [官网](https://sdk.cloudroom.com) 一 您可以在此联系官方技术支持

## 📄 License

MIT许可
