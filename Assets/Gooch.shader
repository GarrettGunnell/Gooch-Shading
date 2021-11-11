Shader "Custom/Gooch" {

	Properties {
		_Albedo ("Albedo", Color) = (1, 1, 1, 1)
		_Smoothness ("Smoothness", Range(0.01, 1)) = 0.5
		_Warm ("Warm", Color) = (1, 1, 1, 1)
		_Cool ("Cool", Color) = (1, 1, 1, 1)
		_Alpha ("Alpha", Range(0.01, 1)) = 0.5
		_Beta ("Beta", Range(0.01, 1)) = 0.5
	}

	SubShader {

		Pass {
			Tags {
				"RenderType" = "Opaque"
			}

			CGPROGRAM

			#pragma vertex vp
			#pragma fragment fp

			#include "UnityPBSLighting.cginc"

			float4 _Albedo, _Warm, _Cool;

			float _Smoothness, _Alpha, _Beta;

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
				float3 lightDir = normalize(float3(1, 1, 0));
				float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);

                float3 reflectionDir = reflect(-lightDir, i.normal);
                float3 specular = DotClamped(viewDir, reflectionDir);
                specular = pow(specular, _Smoothness * 500);

				float goochDiffuse = (1.0f + dot(lightDir, i.normal)) / 2.0f;

				float3 kCool = _Cool.rgb + _Alpha * _Albedo.rgb;
				float3 kWarm = _Warm.rgb + _Beta * _Albedo.rgb;

				float3 gooch = (goochDiffuse * kWarm) + ((1 - goochDiffuse) * kCool);

                return float4(gooch + specular, 1.0f);
			}

			ENDCG
		}

		Pass {
            Tags {
				"LightMode" = "ShadowCaster"
			}
 
            CGPROGRAM
            #pragma vertex vp
            #pragma fragment fp

            #include "UnityCG.cginc"
 
			struct VertexData {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
			};

            struct v2f {
                float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
            };
 
            v2f vp(VertexData v) {
                v2f o;

				o.pos = UnityClipSpaceShadowCasterPos(v.vertex.xyz, v.normal);
				o.pos = UnityApplyLinearShadowBias(o.pos);
				o.uv = v.uv;

                return o;
            }
 
            float4 fp(v2f i) : SV_Target {
                return 0;
            }

            ENDCG
        }
	}
}