using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// プロジェクション座標変換の過程を可視化する
/// </summary>
public class CoordinateTransformation : MonoBehaviour
{
    [SerializeField] private Camera camera;

    [SerializeField, Range(0, 1000)] private float animationSeconds = 5f;

    private IEnumerator Start()
    {
        var mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;
        var vertices = new List<Vector3>();

        //頂点のインデックスを整える
        //この順番を参照して面ができあがる
        var triangles = new[]
        {
            //視錐台
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
            5, 7, 4,
            //四角錐の底面
            11, 8, 9, 11, 9, 10,
            //四角錐の側面
            12, 13, 14,
            15, 16, 17,
            18, 19, 21,
            21, 22, 23,
        };

        var near = camera.nearClipPlane;
        var far = camera.farClipPlane;

        //カメラのパラメータから視錐台を計算
        var nearFrustumHeight = 2.0f * near * Mathf.Tan(camera.fieldOfView * 0.5f * Mathf.Deg2Rad);
        var nearFrustumWidth = nearFrustumHeight * camera.aspect;
        var farFrustumHeight = 2.0f * far * Mathf.Tan(camera.fieldOfView * 0.5f * Mathf.Deg2Rad);
        var farFrustumWidth = farFrustumHeight * camera.aspect;

        var farHalf = far / 2;

        //視錐台を可視化するための頂点
        //四角錐の頂点を作成する
        vertices = new List<Vector3>
        {
            // 0,1,2,3,4,5,6,7
            new Vector3(nearFrustumWidth * -0.5f, nearFrustumHeight * -0.5f, near),
            new Vector3(nearFrustumWidth * 0.5f, nearFrustumHeight * -0.5f, near),
            new Vector3(nearFrustumWidth * -0.5f, nearFrustumHeight * 0.5f, near),
            new Vector3(nearFrustumWidth * 0.5f, nearFrustumHeight * 0.5f, near),
            new Vector3(farFrustumWidth * -0.5f, farFrustumHeight * -0.5f, far),
            new Vector3(farFrustumWidth * 0.5f, farFrustumHeight * -0.5f, far),
            new Vector3(farFrustumWidth * -0.5f, farFrustumHeight * 0.5f, far),
            new Vector3(farFrustumWidth * 0.5f, farFrustumHeight * 0.5f, far),

            // 8,9,10,11
            new Vector3(0, 0, farHalf),
            new Vector3(10, 0, farHalf),
            new Vector3(10, 0, farHalf + 10),
            new Vector3(0, 0, farHalf + 10),
            // 12,13,14
            new Vector3(0, 0, farHalf),
            new Vector3(5f, 10, farHalf + 5f),
            new Vector3(10, 0, farHalf),
            // 15,16,17
            new Vector3(10, 0, farHalf),
            new Vector3(5f, 10, farHalf + 5f),
            new Vector3(10, 0, farHalf + 10f),
            // 18,19,20
            new Vector3(10, 0, farHalf + 10f),
            new Vector3(5f, 10, farHalf + 5f),
            new Vector3(0, 0, farHalf + 10f),
            // 21,22,23
            new Vector3(0, 0, farHalf + 10f),
            new Vector3(5f, 10, farHalf + 5f),
            new Vector3(0, 0, farHalf),
        };

        mesh.Clear();
        mesh.SetVertices(vertices);
        mesh.SetTriangles(triangles,0);
        mesh.RecalculateBounds();
        yield return new WaitForSeconds(3.0f);
        StartCoroutine(UpdateVertices(vertices,mesh));
    }

    /// <summary>
    /// 頂点をカメラの視錐台に合わせた状態に更新する
    /// </summary>
    /// <param name="vertices">頂点リスト</param>
    /// <param name="mesh">変更を適用したいメッシュ</param>
    private IEnumerator UpdateVertices(List<Vector3> vertices,Mesh mesh)
    {
        var vertexList = new List<Vector4>();

        //VP行列を適用する
        for (var i = 0; i < vertices.Count; i++)
        {
            //頂点情報を4次元に
            var vertex = new Vector4(vertices[i].x, vertices[i].y, vertices[i].z, 1);
            //VP行列を作成
            var mat = camera.projectionMatrix * camera.worldToCameraMatrix;
            //VP行列を適用
            vertex = mat * vertex;
            //vertex /= vertex.w;
            //メッシュに対して頂点を適用
            vertices[i] = vertex;
            mesh.vertices = vertices.ToArray();
            mesh.RecalculateBounds();

            //アニメーション用に頂点リストに追加
            vertexList.Add(vertex);
        }

        yield return new WaitForSeconds(3.0f);

        //プロジェクション座標変換の最後の工程である除算を行う
        for (var i = 0; i < vertices.Count; i++)
        {
            var vertex = vertexList[vertexList.Count - 1 - i];
            StartCoroutine(VertexAnimationCoroutine(vertices,vertex,i,mesh));
        }
    }

    /// <summary>
    /// プロジェクションの過程を頂点アニメーションで可視化する
    /// </summary>
    /// <param name="vertices">頂点リスト</param>
    /// <param name="vertex">動かしたい頂点</param>
    /// <param name="index">頂点のインデックス</param>
    /// <param name="mesh">変更を適用したいメッシュ</param>
    private IEnumerator VertexAnimationCoroutine(List<Vector3> vertices, Vector4 vertex, int index,Mesh mesh)
    {
        var startTime = Time.time;
        var spendSeconds = 0f;
        while (spendSeconds < animationSeconds)
        {
            spendSeconds = Time.time - startTime;
            yield return null;
            // W除算
            vertex /= Mathf.Lerp(1, vertex.w, spendSeconds / animationSeconds);
            //メッシュに対して頂点を適用
            vertices[index] = vertex;
            mesh.vertices = vertices.ToArray();
            mesh.RecalculateBounds();
        }
    }
}