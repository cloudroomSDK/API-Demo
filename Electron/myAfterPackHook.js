const path = require('path')
const fs = require('fs')
// mac平台需要在渲染进程添加NSAllowsArbitraryLoads权限，sdk将有http访问的权限
// 此段代码近对构建的程序生效，如果您想在开发模式里添加，需要修改下面这个路径的文件
// node_modules/electron/dist/Electron.app/Contents/Frameworks/Electron Helper (Renderer).app/Contents/Info.plist
exports.default = async function (context) {
    const { electronPlatformName, appOutDir, packager } = context;
    console.log(electronPlatformName)
    if (electronPlatformName === 'darwin') {
        const { productName } = packager.appInfo;
        const xmlPath = path.join(appOutDir, `/${productName}.app/Contents/Frameworks/${productName} Helper (Renderer).app/Contents/Info.plist`);
        const str = fs.readFileSync(xmlPath, {
            encoding: 'utf-8'
        });
        const newContent = `<key>NSAppTransportSecurity</key><dict><key>NSAllowsArbitraryLoads</key><true/></dict></dict>`
        const newStr = str.replace(/<\/dict><\/plist>$/, `${newContent}</dict></plist>`);
        fs.writeFileSync(xmlPath, newStr);
    }
}