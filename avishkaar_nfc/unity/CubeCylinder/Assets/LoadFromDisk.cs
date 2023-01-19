using System.Collections;
using System.Collections.Generic;
using System.IO;
using FlutterUnityIntegration;
using UnityEngine;

public class LoadFromDisk : MonoBehaviour
{
   [SerializeField] AssetBundle myLoadedAssetBundle;

    void Start()
    {
         Debug.Log(Application.persistentDataPath);
         myLoadedAssetBundle = AssetBundle.LoadFromFile(Path.Combine(Application.persistentDataPath, "shapes"));
      
        if (myLoadedAssetBundle == null)
        {
            Debug.Log("Failed to load AssetBundle!");
            UnityMessageManager.Instance.SendMessageToFlutter("Failed to load AssetBundle!");
            return;
        }
       
       Debug.Log("Success to load AssetBundle!");
        
        // myLoadedAssetBundle.Unload(false);
    }

    public void SpawObject(string name)
    {
        GameObject prefab = (GameObject)Instantiate(myLoadedAssetBundle.LoadAsset(name));
    }
}
