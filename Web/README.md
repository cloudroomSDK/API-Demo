# Web API Demo

> 项目展示了 WebRTC API 接口的使用场景，方便客户了解 API 接口功能并快速接入到现有工程中。

[在线演示](https://sdk.cloudroom.com/web/rtc/apidemo/)   [技术文档](https://docs.cloudroom.com/sdk/document/intro/README?platform=Web)

项目采用vue + vue-cli + vuex + vue-router + element-ui技术栈。

## Build Setup

```bash
# 安装依赖
npm install

# 建议不要直接使用 cnpm 安装以来，会有各种诡异的 bug。可以通过如下操作解决 npm 下载速度慢的问题
npm install --registry=https://registry.npm.taobao.org

# 启动服务
npm run dev
```

浏览器访问 [http://localhost:9528/web/rtc/apidemo/](http://localhost:9528/web/rtc/apidemo/)

## 发布

```bash
# 构建测试环境
npm run build:stage

# 构建生产环境
npm run build:prod
```

## 其它

```bash
# 预览发布环境效果
npm run preview

# 预览发布环境效果 + 静态资源分析
npm run preview -- --report

# 代码格式检查
npm run lint

# 代码格式检查并自动修复
npm run lint -- --fix
```
