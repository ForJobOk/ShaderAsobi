using UnityEngine;

/// <summary>
/// トポロジを変更する
/// </summary>
public class WireFrame : MonoBehaviour
{
    /// <summary>
    /// メッシュ
    /// </summary>
    private Mesh mesh;

    void Start()
    {
        mesh = GetComponent<MeshFilter>().sharedMesh;

        if (mesh.GetTopology(0) == MeshTopology.Triangles)
        {
            // メッシュをワイヤーフレームで再構築する
            mesh.SetIndices(MakeIndices(mesh.triangles), MeshTopology.Lines, 0);
        }
    }

    /// <summary>
    /// 三角形の頂点の配列から、三角形の辺の頂点の配列を生成する
    /// </summary>
    private int[] MakeIndices(int[] triangles)
    {
        var indices = new int[2 * triangles.Length];
        var i = 0;
        for (int t = 0; t < triangles.Length; t += 3)
        {
            indices[i++] = triangles[t];
            indices[i++] = triangles[t + 1];
            indices[i++] = triangles[t + 1];
            indices[i++] = triangles[t + 2];
            indices[i++] = triangles[t + 2];
            indices[i++] = triangles[t];
        }

        return indices;
    }
}