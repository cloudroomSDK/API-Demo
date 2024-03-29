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
}
