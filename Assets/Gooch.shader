Shader "Custom/Gooch" {

	Properties {
		_Albedo ("Albedo", Color) = (1, 1, 1, 1)
		_Smoothness ("Smoothness", Range(0.01, 1)) = 0.5
	}

	SubShader {

		Pass {
			Tags {
				"LightMode" = "ForwardBase"
			}

			CGPROGRAM

			#pragma vertex vp
			#pragma fragment fp

			#include "UnityPBSLighting.cginc"

			float4 _Albedo;

			float _Smoothness;

			struct VertexData {
				float4 position : POSITION;
				float3 normal : NORMAL;
				//float2 uv : TEXCOORD0;
			};

			struct v2f {
				float4 position : SV_POSITION;
				//float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
			};

			v2f vp(VertexData v) {
				v2f i;
				i.position = UnityObjectToClipPos(v.position);
				i.worldPos = mul(unity_ObjectToWorld, v.position);
				i.normal = UnityObjectToWorldNormal(v.normal);
				return i;
			}

			float4 fp(v2f i) : SV_TARGET {
				i.normal = normalize(i.normal);
				float3 lightDir = _WorldSpaceLightPos0.xyz;
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 col = _Albedo.rgb;

                float3 diffuse = col * DotClamped(lightDir, i.normal);

                float3 reflectionDir = reflect(-lightDir, i.normal);
                float3 specular = DotClamped(viewDir, reflectionDir);
                specular = pow(specular, _Smoothness * 100);

                return float4(diffuse + specular, 1.0f);
			}

			ENDCG
		}
	}
}