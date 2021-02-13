using UnityEngine;

/// <summary>
/// マウスから出たRayとオブジェクトの衝突座標をShaderに渡す
/// 適当なオブジェクトにアタッチ
/// </summary>
public class MouseRayHitPointSendToShader : MonoBehaviour
{
    /// <summary>
    /// ポインターを出したいオブジェクト
    /// 前提：Shaderは座標受け取りに対応したものを適用
    /// </summary>
    [SerializeField] private Renderer _renderer;

    /// <summary>
    /// Shader側で定義済みの座標を受け取る変数
    /// </summary>
    private string propId = "_MousePosition";
    
    private Material mat;

    void Start ()
    {
        mat = _renderer.material;
    }
    
    void Update () 
    {
        //マウスの入力
        if (Input.GetMouseButton (0)) 
        {
            //Ray出す
            Ray ray = Camera.main.ScreenPointToRay (Input.mousePosition);
            RaycastHit hit_info = new RaycastHit ();
            float max_distance = 100f;

            bool is_hit = Physics.Raycast (ray, out hit_info, max_distance); 

            //Rayとオブジェクトが衝突したときの処理を書く
            if (is_hit) 
            {
                //衝突
                Debug.Log(hit_info.point);
                //Shaderに座標を渡す
                mat.SetVector(propId, hit_info.point);
            }   
        }
    }
}