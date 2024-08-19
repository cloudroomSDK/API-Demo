# uni-app API Demo

项目展示了 uni-app API 接口的使用场景，方便客户了解 API 接口功能并快速接入到现有项目中。

> uni-app RTC SDK 是基于云屋RTC Android、iOS SDK 封装，仅支持App端。如您需要使用uni-app构建小程序端，请参阅 [Api Demo Uniapp 小程序](https://github.com/cloudroomSDK/API-Demo/tree/main/MiniApp)

[技术文档](https://docs.cloudroom.com/sdk/document/intro/README?platform=uniapp)

## 🚀 快速开始

### 环境要求

  * HBuilder 3.0.0 或以上版本
  * iOS 11.0 或以上版本
  * Android 4.4 或以上版本

### 创建账号
1. 您需要在云屋[SDK官网](https://sdk.cloudroom.com/)注册账号并创建项目，具体流程参见[准备工作](https://docs.cloudroom.com/sdk/document/fastIntegration/beforeDevelop?platform=uniapp)
1. 项目创建完成，获取到`AppId`和`AppSecret`，选择以下之一方式：
    - 在`config/index.js`文件中修改对应的值
    - 启动项目后，在设置界面中填入对应的值

### 步骤

1.  克隆项目

    ```
    git clone https://github.com/cloudroomSDK/API-Demo.git
    ```

1. 使用HBuilder运行"uni-app"项目

1. 在"manifest.json"文件中"应用标识"处点击重新获取

1. 点击"菜单栏"-"运行"-"运行到手机或者模拟器"-"制作自定义调试基座"，制作对应平台的自定义调试基座。(必须步骤)
1. 点击"菜单栏"-"运行"-"运行到手机或者模拟器"-"运行到Android App基座"或者"运行到iOS App基座",勾选"使用自定义基座运行"。(必须步骤)


您也可以参阅[图文文档](https://docs.cloudroom.com/sdk/document/fastIntegration/createProject?platform=uniapp)


## 📖 演示场景

- **基础功能:**

| 模块 | 体验功能  | 
|----- | -------- | 
| 语音通话 | 开关麦克风、切换听筒 |
| 视频通话 | 切换摄像头、开关摄像头、多方通话  |
| 视频设置 | 摄像头切换，分辨率、码率等调节   |
| 屏幕共享 | 共享屏幕或观看他人的屏幕  |

- **高级演示:**

| 模块 | 体验功能  | 
|----- | -------- | 
| 本地录制 | 本地录制房间内的视频画面，文件存储在本地 |
| 云端录制 | 服务端录制房间内的视频画面，文件存储在云端  |
| 影音共享 | 共享本地或者观看他人的媒体视频  |
| 房间消息 | 房间内的IM消息通道  |

## 🔖 附录

- [开发者文档](https://docs.cloudroom.com/sdk/document/intro/ProductSummary?platform=uniapp)
- [其他平台SDK下载](https://sdk.cloudroom.com/pages/download#sdk)
- [API Demo](https://github.com/cloudroomSDK/API-Demo)
- [官网](https://sdk.cloudroom.com) 一 您可以在此联系官方技术支持

## 📄 License

MIT许可