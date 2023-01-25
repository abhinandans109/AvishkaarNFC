using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class AssetDownloader : MonoBehaviour
{
    //variables 
    [SerializeField] AssetBundle myLoadedAssetBundle;
    [SerializeField] AssetBundle myMaterialBundle;
    public GameObject Shape;

    // script references
    GameManager gameManager;
   
    void Start()
    {
        gameManager = FindObjectOfType<GameManager>();
        Debug.Log(Application.persistentDataPath);
        //  myLoadedAssetBundle = AssetBundle.LoadFromFile(Path.Combine(Application.persistentDataPath, "game1"));
        // myLoadedAssetBundle.Unload(false);
    }


    public void SpawObject(string name)
    {
        GameObject Object = (GameObject)Instantiate(myLoadedAssetBundle.LoadAsset(name));
    }

    public void GetAssetBundle(string name)
    {  
        myLoadedAssetBundle = AssetBundle.LoadFromFile(Path.Combine(Application.persistentDataPath, "game1"));
        myMaterialBundle = AssetBundle.LoadFromFile(Path.Combine(Application.persistentDataPath, "materials"));
        GetAllScenes();
        if (myLoadedAssetBundle == null)
        {
            Debug.Log("Failed to load AssetBundle!");    
        }
        if (myMaterialBundle == null)
        {
            Debug.Log("Failed to load MaterialBundle!");
        }
    }

    public void GetAllScenes()
    {
        gameManager.scenePath = myLoadedAssetBundle.GetAllScenePaths();
    }

    public Material[] GetAllMaterials()
    {
        Material[] temp = myMaterialBundle.LoadAllAssets<Material>();
        return temp;
    }



    public void GetMaterials( string name)
    {
        Material[] prefabs = (myLoadedAssetBundle.LoadAllAssets<Material>());

        for (int i = 0; i < prefabs.Length; i++)
        {
            if (name == prefabs[i].name)
            {
                // set materials for the object
                Shape.GetComponent<MeshRenderer>().material = prefabs[i];
                break;
            }
        }
    }
}
