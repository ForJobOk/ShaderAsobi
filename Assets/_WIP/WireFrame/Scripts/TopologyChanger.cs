using UnityEngine;

/// <summary>
/// トポロジーを変更する
/// </summary>
public class TopologyChanger : MonoBehaviour
{
    /// <summary>
    /// メッシュ
    /// </summary>
    private Mesh mesh;

    void Start()
    {
        mesh = GetComponent<MeshFilter>().sharedMesh;

        if (mesh.GetTopology(0) == MeshTopology.Triangles
            && mesh.triangles != null
            && mesh.triangles.Length > 0)
        {
            // メッシュをワイヤーフレームで再構築する
            mesh.SetIndices(MakeIndices(mesh.triangles), MeshTopology.Lines, 0);
        }
    }

    /// <summary>
    /// 三角形の頂点の配列から、三角形の辺の頂点の配列を生成する
    /// </summary>
    /// <param name="triangles">三角形の頂点の配列</param>
    /// <returns>三角形の辺の頂点の配列</returns>
    private int[] MakeIndices(int[] triangles)
    {
        // 三角形の辺の頂点の数は、三角形の頂点の数の2倍
        int[] indices = new int[2 * triangles.Length];
        int i = 0;
        for (int t = 0; t < triangles.Length; t += 3)
        {
            indices[i++] = triangles[t]; //start
            indices[i++] = triangles[t + 1]; //end
            indices[i++] = triangles[t + 1]; //start
            indices[i++] = triangles[t + 2]; //end
            indices[i++] = triangles[t + 2]; //start
            indices[i++] = triangles[t]; //end
        }

        return indices;
    }
}