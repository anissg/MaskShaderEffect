Shader "Unlit/ScreenSpaceTexture"
{
    Properties
    {
        _MainTex("Screen Space Texture", 2D) = "white" {}
        _MaskTex("Mask", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screen_pos : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;

            float4 _MaskTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MaskTex);
                o.screen_pos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.screen_pos.xy / i.screen_pos.w;
                float4 col = tex2D(_MainTex, uv);
                float4 mask = tex2D(_MaskTex, i.uv);
                col.a = mask.r;
                return col;
            }
            ENDCG
        }
    }
}
