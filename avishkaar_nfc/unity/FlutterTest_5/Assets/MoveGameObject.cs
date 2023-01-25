using UnityEngine;
using UnityEngine.SceneManagement;

public class MoveGameObject : MonoBehaviour
{
    public void Move(string scene)
    {
        Scene newScene = SceneManager.GetSceneByName(scene);
        SceneManager.MoveGameObjectToScene(this.gameObject, newScene);
     
      //  SceneManager.UnloadSceneAsync(SceneManager.GetActiveScene());
      //  SceneManager.LoadSceneAsync(scene, LoadSceneMode.Additive);
    }
}





