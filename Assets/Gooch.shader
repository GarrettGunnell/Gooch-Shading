Shader "Unlit/Gooch" {
    Properties {
        _Albedo ("Albedo", Color) = (1, 1, 1, 1)
    }

    SubShader {

        Pass {
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            #include "UnityStandardBRDF.cginc"

            struct VertexData {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                //float2 uv : TEXCOORD0;
            };

            struct v2f {
                //float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            float3 _Albedo;

            v2f vp(VertexData v) {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);

                return o;
            }

            fixed4 fp(v2f i) : SV_Target {
                // sample the texture
                float3 col = _Albedo.rgb;

                i.normal = normalize(i.normal);
                float light = DotClamped(_WorldSpaceLightPos0.xyz, i.normal);

                return float4(col * light, 1);
            }
            ENDCG
        }
    }
}
