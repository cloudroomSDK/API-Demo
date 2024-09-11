# HarmonyOS NEXT Api Demo

HarmonyOS NEXT Api Demo是一个开源项目，将向您展示如何将HarmonyOS RTCSDK集成到您的项目中的不同场景。

## 🚀 快速开始

### 环境要求

* 已通过授权的华为开发者账号。可在[华为开发者联盟](https://developer.huawei.com/consumer/cn/)注册账号。
* 华为 [DevEco Studio](https://developer.huawei.com/consumer/cn/deveco-studio/#download) 5.0.3.200 或以上版本
* HarmonyOS NEXT Developer Beta1 或以上版本的操作系统的真机或模拟器，且已开启“允许调试”选项。
* 已注册[云屋开发者](beforeDevelop.md)账号，并获取到AppID和AppSecret。
* 您需要在云屋[SDK官网](https://sdk.cloudroom.com/)注册账号并创建项目，具体流程参见[准备工作](https://docs.cloudroom.com/sdk/document/fastIntegration/beforeDevelop?platform=Electron)

### 步骤
1. 克隆仓库
```bash
git clone git@github.com:cloudroomSDK/API-Demo.git
```
2. 用DevEco Studio打开HarmonyOS文件夹

3. 工程加载后，将从SDK后台获取到的`AppId`和`AppSecret`填入到以下之一方式：
   - 在`entry/src/main/ets/common/LoginConfig.ets`文件中修改`defaultConfig`对象里对应的值
   - 启动App后，在设置界面中填入对应的值
4. 重新签名。点击`文件->项目结构->Signing Configs->Automatically generate signature`后根据提示进行签名
5. 连接手机或模拟器，运行项目


## 📖 演示场景

- **基本功能:**

| 流程   | 描述              | 
|------|-----------------| 
| 语音通话 | 麦克风、扬声器切换，音量大小调节 |
| 视频通话 | 开关摄像头、多方通话 |
| 视频设置 | 摄像头切换，分辨率、码率等调节 |
| 屏幕共享 | 可共享自己的屏幕或者观看他人的屏幕  |

- **进阶功能:**

| 模块 | 体验功能  | 
|----- | -------- | 
| 本地录制 | 本地录制房间内的视频画面，文件存储在本地  |
| 云端录制 | 服务端录制房间内的视频画面，文件存储在云端   |
| 影音共享 | 可共享自己的媒体文件或者观看他人正在共享的媒体  |
| 房间消息 | 房间内的IM消息通道  |

## 🔖 附录

- [开发者文档](https://docs.cloudroom.com/sdk/document/intro/README?platform=HarmonyOS)
- [其他平台SDK下载](https://sdk.cloudroom.com/pages/download#sdk)
- [API Demo](https://github.com/cloudroomSDK/API-Demo)
- [官网](https://sdk.cloudroom.com) 一 您可以在此联系官方技术支持

## 📄 License

MIT许可
