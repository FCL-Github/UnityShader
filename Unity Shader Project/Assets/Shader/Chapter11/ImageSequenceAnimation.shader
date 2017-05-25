Shader "Unity Shaders Book/Chapter 11/ImageSequenceAnimation"
{
	Properties
	{
		_MainTex ("Image Sequence", 2D) = "white" {}
		_Color("Color Tint",Color)=(1,1,1,1)
		_HorizontalAmount("Horizontal Amount",Float)=4
		_VerticalAmount("Vertical Amount",Float)=4
		_Speed("Speed",Range(1,100))=40
	}
	SubShader
	{
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		Pass
		{
		    Tags{"LightMode"="ForwardBase"}
		    ZWrite Off
		    Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
			    float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
			};
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _HorizontalAmount;
			float _VerticalAmount;
			float _Speed;
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float time = floor(_Time.y*_Speed);
				float row = floor(time / _HorizontalAmount);
				float column = fmod(time,_HorizontalAmount);

				half2 uv = half2(i.uv.x/_HorizontalAmount,i.uv.y/_VerticalAmount);
				uv.x += column/_HorizontalAmount;
				uv.y -= row/_VerticalAmount;

				fixed4 col = tex2D(_MainTex, uv);
				col.rgb *= _Color;
				return col;
			}
			ENDCG
		}
	}
}
