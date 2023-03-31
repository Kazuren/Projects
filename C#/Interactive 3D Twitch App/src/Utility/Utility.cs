using System;
using System.Collections.Generic;
using Godot;

using System.Text.RegularExpressions;
using System.Linq;

using System.Net;
using System.Net.Http;
using System.Net.Security;
using System.Net.WebSockets;
using System.Security.Cryptography.X509Certificates;
using X509Certificate = System.Security.Cryptography.X509Certificates.X509Certificate;

static class Utility
{
  public static void NestedPrint(Dictionary<string, object> dict, int level = 0)
  {
    foreach (var item in dict)
    {
      if (item.Value is Dictionary<string, object> nested)
      {
        GD.Print($"{new string(' ', level)}{item.Key}:");
        NestedPrint(nested, level + 1);
      }
      else
      {
        GD.Print($"{new string(' ', level)}{item.Key} = {item.Value}");
      }
    }
  }

  public static string[] GetFiles(string path, string format)
  {
    List<string> files = new List<string>();
    Godot.Directory dir = new Godot.Directory();
    if (dir.Open(path) == Error.Ok)
    {
      dir.ListDirBegin();
      string fileName = dir.GetNext();
      while (fileName != String.Empty)
      {
        fileName = fileName.Replace(".import", String.Empty); // Fixes exported build file path
        bool isDirectory = dir.CurrentIsDir();
        if (!isDirectory)
        {
          if (fileName.EndsWith(format))
          {
            files.Add($"{path}/{fileName}");
          }
        }
        fileName = dir.GetNext();
      }
    }
    return files.ToArray();
  }

  public static Node[] GetChildrenRecursive(this Node node)
  {
    List<Node> childrenList = new List<Node>();

    foreach (Node child in node.GetChildren())
    {
      childrenList.Add(child);
      child.GetChildrenRecursive(childrenList);
    }

    return childrenList.ToArray();
  }

  private static void GetChildrenRecursive(this Node node, List<Node> childrenList)
  {
    foreach (Node child in node.GetChildren())
    {
      childrenList.Add(child);
      child.GetChildrenRecursive(childrenList);
    }
  }
  public static void Shuffle<T>(this Random rng, T[] array)
  {
    int n = array.Length;
    while (n > 1)
    {
      int k = rng.Next(n--);
      T temp = array[n];
      array[n] = array[k];
      array[k] = temp;
    }
  }


  public static class Certs
  {
    const string BEGIN_CERT = "-----BEGIN CERTIFICATE-----";
    const string END_CERT = "-----END CERTIFICATE-----";
    const int SPACE_CHAR = 0x20;

    private static List<X509Certificate> trustedRoots = new List<X509Certificate>();
    private static List<string> trustedHashes = new List<string>();
    private static bool loaded = false;
    public static void Load()
    {
      if (loaded)
        return;
      loaded = true;

      // string[] cert_paths = {
      //   "res://certificates.cer",
      //   "res://OU=Starfield Class 2 Certification Authority,O=Starfield Technologies_, Inc.,C=US.crt",
      //   "res://id.twitch.tv.crt"
      // };

      // for (int i = 0; i < cert_paths.Length; i++)
      // {
      //   var path = cert_paths[i];
      //   var file = new File();
      //   file.Open(path, File.ModeFlags.Read);
      //   var content = file.GetBuffer((long)file.GetLen());

      //   validCerts = new List<string>();
      //   validCerts.Add((new X509Certificate2(content)).GetCertHashString());
      //   GD.Print((new X509Certificate2(content)).GetCertHashString());

      //   ServicePointManager.ServerCertificateValidationCallback += (sender, certificate, chain, errors) =>
      //   {
      //     GD.Print(chain.ChainElements[0].Certificate.GetCertHashString());
      //     var is_trusted = validCerts.Contains(chain.ChainElements[0].Certificate.GetCertHashString());
      //     return errors == SslPolicyErrors.None || is_trusted;
      //   };
      // }

      ServicePointManager.ServerCertificateValidationCallback = CertCheck;

      // foreach (StoreLocation storeLocation in (StoreLocation[])Enum.GetValues(typeof(StoreLocation)))
      // {
      //   foreach (StoreName storeName in (StoreName[])
      //           Enum.GetValues(typeof(StoreName)))
      //   {
      //     X509Store store = new X509Store(storeName, storeLocation);
      //     try
      //     {
      //       store.Open(OpenFlags.ReadOnly);
      //       var certs = store.Certificates;
      //       foreach (var cert in certs)
      //       {
      //         string hash = cert.GetCertHashString();
      //         GD.Print($"SSL Cert for {cert.Subject} from {cert.Issuer}", cert.GetExpirationDateString());
      //         GD.Print(hash);
      //         GD.Print(cert.GetRawCertDataString());
      //         trustedHashes.Add(hash);
      //       }
      //       //var cerrt = new X509Certificate()

      //       GD.Print("Yes    {0,4}  {1}, {2}",
      //           store.Certificates.Count, store.Name, store.Location);
      //     }
      //     catch (CryptographicException)
      //     {
      //       GD.Print("No           {0}, {1}",
      //           store.Name, store.Location);
      //     }
      //   }
      // }

      File f = new File();
      Error err = f.Open("res://ssl/certificates/certificates.cer", File.ModeFlags.Read);
      if (err != Error.Ok)
      {
        GD.PushError($"Failed to load 'res://ssl/certificates/certificates.cer': {err}");
        f.Close();
        return;
      }
      string text = f.GetAsText();
      f.Close();
      int i = 0;
      while (i < text.Length)
      {
        int next = text.Find(BEGIN_CERT, i);
        if (next == -1)
          break;
        next += BEGIN_CERT.Length;
        int end = text.Find(END_CERT, next);
        if (end == -1)
          break;
        // Load cert
        string pem = new string(text.Substring(next, end - next)
          .Where(c => c > SPACE_CHAR).ToArray());
        X509Certificate cert = new X509Certificate(Convert.FromBase64String(pem));
        string hash = cert.GetCertHashString();
        trustedRoots.Add(cert);
        trustedHashes.Add(hash);
        // GD.Print($"Loaded Root Cert for {cert.Subject} from {cert.Issuer}"
        // , " not trusted, hash: ", hash);
        // Move past
        i = end + END_CERT.Length;
      }
      GD.Print("Loaded SSL Root Certs!",
        "\n---------------------------------------------------------------\n");
    }

    private static X509Certificate getRootCertificate(X509Chain chain)
    {
      var count = chain.ChainElements.Count;
      if (count == 0)
        return null;
      X509ChainElement root = chain.ChainElements[count - 1];
      if (root.ChainElementStatus != null)
        foreach (X509ChainStatus status in root.ChainElementStatus)
          if (status.Status == X509ChainStatusFlags.PartialChain)
            return null;
      return root.Certificate;
    }

    private static bool CertCheck(object sender, X509Certificate certificate
      , X509Chain chain, SslPolicyErrors sslPolicyErrors)
    {
      return true;
      try
      {
        var hash = certificate.GetCertHashString();
        if (trustedHashes.Contains(hash))
          return true;
        var root = getRootCertificate(chain);
        if (root != null && trustedHashes.Contains(root.GetCertHashString()))
          return true;
        long trusted = 0;
        foreach (var el in chain.ChainElements)
        {
          if (trustedHashes.Contains(el.Certificate.GetCertHashString()))
            trusted++;
        }
        GD.PrintErr($"SSL Cert for {certificate.Subject} from {certificate.Issuer}"
          , " not trusted, hash: ", hash, "\n\t", trusted, " of "
          , chain.ChainElements.Count, " elements in chain are trusted.");
        return false;
      }
      catch (Exception ex)
      {
        GD.PrintErr("Error checking SSL certs: ", ex, "\n", ex.StackTrace);
        return false;
      }
    }

    public static HttpClientHandler Handler()
    {
      var h = new HttpClientHandler();
      h.ServerCertificateCustomValidationCallback = CertCheck;
      return h;
    }

    // public static void SetupSocket(ClientWebSocket client)
    // {
    //   client.Options.RemoteCertificateValidationCallback = CertCheck;
    // }
  }

}
