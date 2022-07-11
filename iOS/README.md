# 运行iOS SDK Demo操作步骤

* 首先在官网[下载SDK](https://www.cloudroom.com/api/getDownloadUrlApi?Client=SDK-77)
* 在Demo工程文件目录下新建一个名为`Framework`的文件夹，将下载的`.framework`文件放入其中

# 常见问题

如果操作完找不到SDK，请检查以下几点

* 检查`Bulid Settings->Search Paths -> Framework Search Paths`中的路径，正确的应该是`$(PROJECT_DIR)/Framework`
* 或者清除工程内的framework记录，重新添加，选中工程对应的target，切换至`General`下，转到`Frameworks, Libraries, and Embedded Content`项，点击+号，依次`Add Other -> Add Files`，切到我们工程目录下的Framework文件下，勾选对应的SDK即可，`CloudroomVideoSDK_IOS.framework`为动态库，请选择`Embed`为`Embed & Sign`
* 屏幕共享的`CloudroomReplayKitExt.framework`与主进程App的集成方式一致，如果集成在主进程App则需要共享给子进程App

