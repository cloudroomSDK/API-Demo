import Store from "electron-store";
import { ipcMain } from "electron";
import { Addr, AppId, AppSecret } from "./auth";

const userId = `Electron_${parseInt((Math.random() * 9000).toString()) + 1000}`;

const store = (function () {
  const config = {
    encryptionKey: "Buffer",
    schema: {
      meetId: {
        type: "number",
      },
      addr: {
        type: "string",
        default: Addr,
      },
      appId: {
        type: "string",
        default: AppId,
      },
      appSecret: {
        type: "string",
        default: AppSecret,
      },
      token: {
        type: "string",
        default: "",
      },
      isTokenAuth: {
        type: "boolean",
        default: false,
      },
      protocol: {
        type: "number",
        default: 1,
      },
      userId: {
        type: "string",
        default: userId,
      },
      nickname: {
        type: "string",
        default: userId,
      },
    },
    clearInvalidConfig: true, // 发生 SyntaxError  则清空配置,
  };
  try {
    return new Store(config);
  } catch (error) {
    // 当数据类型改变时，会引发报错，将数据重置
    const store = new Store({ ...config, schema: null });
    store.clear();
    return new Store({ ...config });
  }
})();
ipcMain.on("electron-store-get", async (event, key) => {
  if (!Array.isArray(key)) {
    event.returnValue = store.get(key);
    return;
  }
  const arr = [];
  key.forEach((item) => {
    arr.push(store.get(item));
  });
  event.returnValue = arr;
});
ipcMain.on("electron-store-set", async (event, key, val) => {
  store.set(key, val);
});
ipcMain.on("electron-store-reset", async (event, keys) => {
  store.reset(...keys);
});

ipcMain.on("electron-store-delete", async (event, key) => {
  if (!Array.isArray(key)) {
    key = [key];
  }

  key.forEach((item) => {
    store.delete(item);
  });
});

export default store;
