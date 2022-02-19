using System.Collections;
using UnityEngine;

//[ExecuteAlways]
public class CoordinateTransformation : MonoBehaviour {

    [SerializeField]
    private Camera camera;
    
    [SerializeField,Range(0,1000)]
    private float animationSeconds = 5f;

    private Mesh mesh;
    private Vector3[] vertices;

    private void Awake()
    {
        mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;
        vertices = new Vector3[8];
        
        // メッシュを初期化
        var triangles = new []{
            0, 2, 1,
            1, 2, 3,
            1, 3, 5,
            7, 5, 3,
            3, 2, 7,
            6, 7, 2,
            2, 0, 6,
            4, 6, 0,
            0, 1, 4,
            5, 4, 1,
            4, 7, 6,
            5, 7, 4
        };
      
        mesh.vertices = vertices;
        mesh.triangles = triangles;
        UpdateVertices();
    }

    /// <summary>
    /// 頂点をカメラの視錐台に合わせたものに更新する
    /// </summary>
    private void UpdateVertices()
    {
        var near = camera.nearClipPlane;
        var far = camera.farClipPlane;

        // 視錐台の大きさの求め方は下記を参考
        // https://docs.unity3d.com/jp/current/Manual/FrustumSizeAtDistance.html
        var nearFrustumHeight = 2.0f * near * Mathf.Tan(camera.fieldOfView * 0.5f * Mathf.Deg2Rad);
        var nearFrustumWidth = nearFrustumHeight * camera.aspect;
        var farFrustumHeight = 2.0f * far * Mathf.Tan(camera.fieldOfView * 0.5f * Mathf.Deg2Rad);
        var farFrustumWidth = farFrustumHeight * camera.aspect;

        vertices[0] = new Vector3(nearFrustumWidth * -0.5f, nearFrustumHeight * -0.5f, near);
        vertices[1] = new Vector3(nearFrustumWidth * 0.5f, nearFrustumHeight * -0.5f, near);
        vertices[2] = new Vector3(nearFrustumWidth * -0.5f, nearFrustumHeight * 0.5f, near);
        vertices[3] = new Vector3(nearFrustumWidth * 0.5f, nearFrustumHeight * 0.5f, near);
        vertices[4] = new Vector3(farFrustumWidth * -0.5f, farFrustumHeight * -0.5f, far);
        vertices[5] = new Vector3(farFrustumWidth * 0.5f, farFrustumHeight * -0.5f, far);
        vertices[6] = new Vector3(farFrustumWidth * -0.5f, farFrustumHeight * 0.5f, far);
        vertices[7] = new Vector3(farFrustumWidth * 0.5f, farFrustumHeight * 0.5f, far);

        // VP行列を適用する
        for (var i = 0; i < vertices.Length; i++) {
            // 検証のため頂点情報を4次元に
            var vertex = new Vector4(vertices[i].x, vertices[i].y, vertices[i].z, 1);
            // VP行列を作成
            var mat = camera.projectionMatrix * camera.worldToCameraMatrix;
            // VP行列を適用
            vertex = mat * vertex;
           
            StartCoroutine(VertexAnimationCoroutine(vertex, i));
        }
    }

    
    private IEnumerator VertexAnimationCoroutine(Vector4 vertex,int index)
    {
        var startTime = Time.time;
        var spendSeconds = 0f;
        while (spendSeconds < animationSeconds)
        {
            spendSeconds = Time.time - startTime;
            Debug.Log(spendSeconds/animationSeconds);
            yield return null;
            // W除算
            vertex /= Mathf.Lerp(1,vertex.w,spendSeconds/animationSeconds);
            Debug.Log(vertex);
            vertices[index] = vertex;
            mesh.vertices = vertices;
            mesh.RecalculateBounds();
        }
       
    }
}