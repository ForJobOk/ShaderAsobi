using System.Collections.Generic;
using System.Linq;
using UnityEngine;

namespace Ono.Utility
{
    /// <summary>
    /// Vector3の拡張メソッド
    /// </summary>
    public static class Vector3Extenstion
    {
        /// <summary>
        /// Vector3のListに対して平均値を算出する
        /// </summary>
        /// <param name="vectors"></param>
        /// <returns></returns>
        public static Vector3 Average(this IEnumerable<Vector3> vectors)
        {
            return vectors.Sum() / vectors.Count();
        }
        
        private static Vector3 Sum(this IEnumerable<Vector3> vectors)
        {
            Vector3 sum = Vector3.zero;
            foreach (Vector3 v in vectors)
            {
                sum += v;
            }

            return sum;
        }
    }
}