Texture2D tex: register(t0);
Texture2D texUV : register(t1);
SamplerState samplerState : register(s0);
RWTexture2D<uint> outTexture : register(u0); // ע�⣺����ʹ��uint��ʽ����ΪR10G10B10A2���Ա�ʾΪһ��32λ����

[numthreads(16, 16, 1)]

void main(uint3 dtid : SV_DispatchThreadID)
{
    uint Y = tex.SampleLevel(samplerState, dtid.xy,0).r; // ��ȡYͨ����ֵ������Ӧ��RGB��Rͨ��
    uint U = texUV.SampleLevel(samplerState, dtid.xy * 0.5,0).r;
    uint V = texUV.SampleLevel(samplerState, dtid.xy * 0.5,0).g; //420Ϊһ���size
    // Simplified HLG to PQ conversion for Y (luminance)
    float L;
    if (Y <= 0.5)
        L = sqrt(Y);
    else
        L = pow((Y + 0.099) / 1.099, 1.0 / 0.45);

    // Replace with accurate PQ encoding curve as needed.
    // Here we're using a power curve as a placeholder.
    L = pow(L, 12.0);

    //yuv.x = L;
    float R = L * 1024 + 1.402 * (V * 1024 - 512);

    float G = L * 1024 - 0.344136 * (U * 1024 - 512) - 0.714136 * (V * 1024 - 512);

    float B = L * 1024 + 1.772 * (U * 1024 - 512);

    R = clamp(R, 0, 1023);
    G = clamp(G, 0, 1023);
    B = clamp(B, 0, 1023);

    uint a2bit = 3;
    uint intR = (uint)R;
    uint intG = (uint)G;
    uint intB = (uint)B;

    uint packedValue = ((a2bit & 0x3FF) << 30) | ((intB & 0x3FF )<< 20) | ((intG & 0x3FF) << 10) | (intR & 0x3FF);

    outTexture[dtid.xy] = packedValue;
}
