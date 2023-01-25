using System;
using System.Collections;
using System.Collections.Generic;
using FlutterUnityIntegration;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameManager : MonoBehaviour
{
    
    levelManager lvlManager;
    AssetDownloader assetDownloader;
    MoveGameObject moveObject;
    ColorChange colorChange;
    Rotate rotate;


    public string[] scenePath;

    public GameObject Player;
    public GameObject LevelManagerObj;
    [SerializeField] Material defaultSkybox;


    void Start()
    {
        
        // reference all working script 
        lvlManager = FindObjectOfType<levelManager>() ;
        assetDownloader = FindObjectOfType<AssetDownloader>();
        moveObject = FindObjectOfType<MoveGameObject>();
        colorChange = FindObjectOfType<ColorChange>();
        rotate = FindObjectOfType<Rotate>();
 
        gameObject.AddComponent<UnityMessageManager>();
         
        GetInitialScene();
      //  Setup();
    }

    // Update is called once per frame
    void Update()
    { 
    
    }

    void HandleWebFnCall(String action)
    {
        switch (action)
        {
            case "pause":
                Time.timeScale = 0;
                break;
            case "resume":
                Time.timeScale = 1;
                break;
            case "unload":
                Application.Unload();
                break;
            case "quit":
                Application.Quit();
                break;
        }
    }

    public void Setup( string s )
    {
        // setup your initial scene
          // 1. load the asset vbundle
        assetDownloader.GetAssetBundle("game1");
          // 2. load all scene path present in bundle
        assetDownloader.GetAllScenes();
        GetMaterialsFromBundle();


    }

    public void LoadSceneFromBundle(string name)  // checking and loading scene
    {
            if (SceneManager.GetSceneByName(name).IsValid())
            {
                Debug.Log("scene already exist");
                return;
            }
            else
            {
            StartCoroutine(LoadLevelFromBundle(name));
            }
       

    }

    [SerializeField] Scene previousScene;
    void GetInitialScene()
    {
        previousScene = SceneManager.GetActiveScene();
       // Debug.Log(previousScene.name);

    }
    IEnumerator LoadLevelFromBundle(string name)
    {
     //   Debug.Log(previousScene.name);
        lvlManager.Player = null;
      //  Debug.Log(lvlManager.Player);
        AsyncOperation asyncLoad =  SceneManager.LoadSceneAsync(name, LoadSceneMode.Additive);
        moveObject.Move(name);

         while(!asyncLoad.isDone)
         {
            yield return null;
         }

        //  FindObjectWithName(name);  trying with existing levelmanager oibject

         asyncLoad.completed += (operation) =>
         {
             // StartCoroutine(SceneSetup());
             lvlManager.SetupScene();
             SceneManager.UnloadSceneAsync(previousScene);
         };
         previousScene = SceneManager.GetSceneByName(name);
       //  Debug.Log(previousScene.name);
         AssignSkybox();
        // Debug.Log("all done");

    }

   
    public void AssignSkybox()
    {
       // Debug.Log("skybox Set");
        UpdateEnvironment(defaultSkybox);
    }

    public static void UpdateEnvironment(Material newSkyboxMaterial)
    {
        RenderSettings.skybox = newSkyboxMaterial;
    }
    public void FindObjectWithName(string name) //using to find level manager is loaded scene
    {
        Debug.Log(SceneManager.GetSceneByName(name).isLoaded);

        Scene scene = SceneManager.GetSceneByName(name);
        GameObject[] rootObjects = scene.GetRootGameObjects();
        foreach (GameObject obj in rootObjects)
        {
            if (obj.name == "LevelManager")
            {
            //    Debug.Log("found");
                LevelManagerObj = obj;
                LevelManagerObj.AddComponent<levelManager>();
                break;
            }
        }
    }


    public void SpawnObjectFromBundle(string name)
    {
        GameObject SceneObect = GameObject.FindGameObjectWithTag("shape");

        if (SceneObect == null)
        {
            assetDownloader.SpawObject(name);
        }
        if (SceneObect != null)
        {
            Destroy(SceneObect.gameObject);
            assetDownloader.SpawObject(name);
        }
    }

    public void FindShapeInScene()  //find shape manually
    {
        Player = GameObject.FindGameObjectWithTag("shape");
        colorChange.Shape = Player;
        rotate.Shape = Player;
        assetDownloader.Shape = Player;
    }

    public void SetPlayer(GameObject go)
    {
        this.Player = go;
        colorChange.Shape = go;
        rotate.Shape = go;
    }

    public void GetMaterialsFromBundle()
    {
        colorChange.Materials = assetDownloader.GetAllMaterials();
        Debug.Log("Materials uploaded from bundle");
    }

    public void ChangeColor(string color)
    {
        colorChange.ColorFromFlutter(color);
    }
    public void SetrotationS(string value)
    {
        rotate.SetRotationSpeed(value);
    }

  

    public void TestButton(string name)
    {
        // SceneManager.LoadScene(Level.name);
    }


}
