import { ipcRenderer } from "electron";
export const get = (key: string) =>
  ipcRenderer.sendSync("electron-store-get", key);
export const set = (property: string, val: any) =>
  ipcRenderer.send("electron-store-set", property, val);
export const reset = (key: string) =>
  ipcRenderer.send("electron-store-reset", key);
export const del = (key: any) => ipcRenderer.send("electron-store-delete", key);

export default {
  get,
  set,
  reset,
  del,
};
