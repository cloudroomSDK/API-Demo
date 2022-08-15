# 运行Android SDK API Demo操作步骤

* 首先在官网[下载SDK](https://www.cloudroom.com/api/getDownloadUrlApi?Client=SDK-75)
* 将SDK包内libs目录下的库放入Demo工程的app/libs目录下

# 常见问题

* 架构选择问题：正常没有模拟器需求情况x86、x86_64是不需要集成的，armeabi-v7a、arm64-v8a架构根据需求自行选择一个或多个打包集成
* 出现加载so库异常问题：检测libs下是否有对应架构的库，app/build.gradle中ndk架构配置是否libs都有对应的库
	defaultConfig {
        ndk {
            abiFilters "armeabi-v7a"
        }
    }
