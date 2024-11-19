const { spawn } = require("child_process");
const path = require('path');
const archArr = [
    "ia32",
    "x64",
    "armv7l",
    "arm64",
    "universal",
]


exports.default = async function (context) {
    return new Promise((resolve, reject) => {
        const { electronPlatformName, arch } = context;
        console.log(`install RTC SDK, platform:${electronPlatformName},arch: ${archArr[arch]}`)
        const cmd = spawn("npm run preinstall", [`--platform=${electronPlatformName}`, `--arch=${archArr[arch]}`], {
            cwd: path.relative(__dirname, 'node_modules/@cloudroom/electron-rtcsdk'),
            stdio: 'inherit',
            shell: true
        })

        cmd.on('exit', (code) => {
            if (code !== 0) {
                reject();
                return;
            }
            console.log('success');
            resolve()
        });
    })
}