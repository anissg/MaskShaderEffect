Shader "Unlit/ObjectSpaceTexture"
{
    Properties
    {
        _MaskedTex("Masked Texture", 2D) = "white" {}
        _MaskedTexSize("Masked Texture size", VECTOR) = (0,0,0,0)
        _MaskedTexPosition("Masked Texture position", VECTOR) = (0,0,0,0)
        _MaskTex("Mask", 2D) = "white" {}
        [Toggle(FLIP_MASK)] _FlipMask("Flip Mask", Float) = 0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma enable_d3d11_debug_symbols
            #pragma kernel CSRenderWipe
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature FLIP_MASK
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 mask_vertex : POSITION;
                float2 mask_uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 mask_vertex : SV_POSITION;
                float2 mask_uv : TEXCOORD0;
                float2 masked_uv : TEXCOORD1;
            };

            sampler2D _MaskedTex;
            float2 _MaskedTexSize;
            float4 _MaskedTexPosition;
            sampler2D _MaskTex;

            float4 _MaskTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.mask_vertex = UnityObjectToClipPos(v.mask_vertex);
                float4 world_vertex = mul(unity_ObjectToWorld, v.mask_vertex);
                o.mask_uv = TRANSFORM_TEX(v.mask_uv, _MaskTex);
                o.masked_uv = ((_MaskedTexPosition - world_vertex) / _MaskedTexSize);
                o.masked_uv.x = -o.masked_uv.x;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float4 col = tex2D(_MaskedTex, i.masked_uv);
                float4 mask = tex2D(_MaskTex, i.mask_uv);
                #ifndef FLIP_MASK
                    col.a = mask.r;
                #else
                    col.a = 1 - mask.r;
                #endif
                return col;
            }
            ENDCG
        }
    }
}
