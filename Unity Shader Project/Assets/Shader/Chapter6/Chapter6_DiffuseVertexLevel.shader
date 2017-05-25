﻿// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 6/Diffuse Vertex-Level"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1.0,1.0,1.0,1.0)
	}
	SubShader
	{
		
		Pass
		{
		    Tags {"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work

			
			#include "Lighting.cginc"

			fixed4 _Diffuse;
			struct a2v
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				fixed3 color : COLOR;
				float4 pos : SV_POSITION;
			};
			
			v2f vert (a2v v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP,v.vertex);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
				fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal,worldLight));

				o.color = ambient + diffuse;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				
				return fixed4(i.color,1.0);
			}
			ENDCG
		}

	}
	Fallback  "Diffuse"
}