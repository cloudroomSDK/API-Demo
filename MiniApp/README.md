# MiniApp Uniapp Api Demo

MiniApp Uniapp Api Demo是一个开源项目，它基于uniapp + vue技术栈，方便客户了解 API 接口功能并快速接入到现有项目中。

## 🚀 快速开始

### 创建账号
  1. 您需要在云屋[SDK官网](https://sdk.cloudroom.com/)注册账号并创建项目，具体流程参见[准备工作](https://docs.cloudroom.com/sdk/document/fastIntegration/beforeDevelop?platform=miniprogram)
  1. 项目创建完成，获取到`AppId`和`AppSecret`，选择以下之一方式：
    - 在`store.js`文件中修改`defaultConfig`对应的值
    - 启动项目后，在设置界面中填入对应的值

### 注意事项
1. [小程序后台不可缺少的配置](https://docs.cloudroom.com/sdk/document/fastIntegration/beforeDevelop?platform=miniprogram#doc_6)
2. [小程序后台开发相关的配置](https://docs.cloudroom.com/sdk/document/fastIntegration/wxconfig?platform=miniprogram)
3. demo中的SDK由官网SDK包中的js文件修改后缀名得到，升级SDK需做同样的操作

### 步骤

```bash
git clone git@github.com:cloudroomSDK/API-Demo.git
```
1. 在Hbuilder 编译器中导入项目`MiniApp`
2. 在`manifest.json`中重新获取uni-app的应用标识
3. 在`manifest.json`小程序配置中，配置开发者小程序的AppID
4. 在Hbuilder 编译器点击`运行`-`运行到小程序模拟器`-`微信开发者工具`

### 使用Vue2版本
1. 在`manifest.json`中切换Vue2版本
2. 将`package/CRSDK/RTC_Miniapp_SDK.min.cjs`重命名为`RTC_Miniapp_SDK.min.js`
3. 将`RTC_Miniapp_SDK.min.cjs.map`重命名为`RTC_Miniapp_SDK.min.js.map`
4. 修改`package/CRSDK/index.js`里的RTCSDK的导入路径

## 📖 演示场景

- **基本演示:**

| 流程 | 描述  | 
|----- | -------- | 
| 分包加载 | 使用分包继承SDK，避免总包过大 |
| 初始化 | 日志、视频等功能的配置  |
| 登录和注销 | 登录是SDK的必要流程，使用前必须登录  |
| 创建、进入和退出房间 | 同一个房间内的用户可相互观看视频  |

- **高级演示:**

| 模块 | 体验功能  | 
|----- | -------- | 
| 音频设置 | 麦克风、扬声器切换，音量大小调节 |
| 视频设置 | 摄像头切换，分辨率、码率等调节  |
| 云端录制 | 服务端录制房间内的视频画面，文件存储在云端   |
| 房间消息 | 房间内的IM消息通道  |

## 🔖 附录

- [开发者文档](https://docs.cloudroom.com/sdk/document/intro/ProductSummary?platform=miniprogram)
- [其他平台SDK下载](https://sdk.cloudroom.com/pages/download#sdk)
- [API Demo](https://github.com/cloudroomSDK/API-Demo)
- [官网](https://sdk.cloudroom.com) 一 您可以在此联系官方技术支持

## 📄 License

MIT许可