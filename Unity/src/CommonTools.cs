using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;


public class CommonTools
{
    public static string MakeMd5(string srcStr)
    {
        if (srcStr.Length == 0)
            return "";

        MD5 md5 = MD5.Create();
        byte[] strMd5Bt = md5.ComputeHash(Encoding.UTF8.GetBytes(srcStr));
        string strRslt = System.BitConverter.ToString(strMd5Bt);
        strRslt = strRslt.Replace("-", "").ToLower();
        return strRslt;
    }

    public static string ReadIniStr(string iniPath, string section, string key, string defValue = "")
    {
        INIParser parser = new INIParser();
        parser.Open(iniPath);
        string readStr = parser.ReadValue(section, key, defValue);
        parser.Close();
        return readStr;
    }

    public static void WriteIniStr(string iniPath, string section, string key, string value)
    {
        INIParser parser = new INIParser();
        parser.Open(iniPath);
        parser.WriteValue(section, key, value);
        parser.Close();
    }

    public static int ReadIniInt(string iniPath, string section, string key, int defValue = 0)
    {
        INIParser parser = new INIParser();
        parser.Open(iniPath);
        int readVal = parser.ReadValue(section, key, defValue);
        parser.Close();
        return readVal;
    }

    public static void ParseRoomUserAttrs(string jsonStr, Dictionary<string, RoomUserAttr> attrDict)
    {
        int pos = 0;
        while (pos < jsonStr.Length)
        {
            string strKey = "";
            string strValue = "";
            int keyStartPos = jsonStr.IndexOf('"', pos);
            int keyStopPos = 0;
            if (keyStartPos > 0)
            {
                keyStopPos = jsonStr.IndexOf('"', keyStartPos + 1);
                if (keyStopPos > keyStartPos)
                {
                    strKey = jsonStr.Substring(keyStartPos + 1, keyStopPos - keyStartPos - 1);
                }
            }

            if (strKey.Length == 0)
                return;

            int valStartPos = jsonStr.IndexOf('{', keyStopPos + 1);
            int valStopPos = 0;
            if (valStartPos > keyStopPos)
            {
                valStopPos = jsonStr.IndexOf('}', valStartPos + 1);
                if (valStopPos > valStartPos)
                {
                    strValue = jsonStr.Substring(valStartPos, valStopPos - valStartPos + 1);
                }
            }

            pos = (valStopPos == 0) ? keyStopPos : valStopPos;
            if (strValue.Length == 0)
                continue;

            RoomUserAttr ruAttr = UnityEngine.JsonUtility.FromJson<RoomUserAttr>(strValue);
            attrDict.Add(strKey, ruAttr);
        }
    }
}
