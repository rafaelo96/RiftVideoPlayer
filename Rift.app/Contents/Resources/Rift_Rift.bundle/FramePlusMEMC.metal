#include <metal_stdlib>
using namespace metal;

constant uint MEMC_DOWNSCALE = 4;
constant uint MEMC_BLOCK_SIZE = 4;
constant int MEMC_SEARCH_RADIUS = 12;

struct MEMCParams {
    uint fullWidth;
    uint fullHeight;
    uint lowWidth;
    uint lowHeight;
    uint vectorWidth;
    uint vectorHeight;
    uint downscale;
    uint blockSize;
    uint searchRadius;
    float timestep;
    float occlusionThreshold;
};

static inline half lumaFromRGB(half3 rgb) {
    return dot(rgb, half3(0.2126h, 0.7152h, 0.0722h));
}

kernel void memcDownsample(
    texture2d<float, access::read> source [[texture(0)]],
    texture2d<half, access::write> lumaOut [[texture(1)]],
    constant MEMCParams& params [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= params.lowWidth || gid.y >= params.lowHeight) { return; }

    const uint2 origin = gid * MEMC_DOWNSCALE;
    half sum = 0.0h;

    #pragma unroll
    for (uint y = 0; y < MEMC_DOWNSCALE; y++) {
        #pragma unroll
        for (uint x = 0; x < MEMC_DOWNSCALE; x++) {
            uint2 p = min(origin + uint2(x, y), uint2(params.fullWidth - 1, params.fullHeight - 1));
            sum += lumaFromRGB(half3(source.read(p).rgb));
        }
    }

    lumaOut.write(half4(sum * half(1.0 / float(MEMC_DOWNSCALE * MEMC_DOWNSCALE))), gid);
}

kernel void memcEstimateMotion(
    texture2d<half, access::read> lowA [[texture(0)]],
    texture2d<half, access::read> lowB [[texture(1)]],
    texture2d<half, access::write> vectorOut [[texture(2)]],
    constant MEMCParams& params [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= params.vectorWidth || gid.y >= params.vectorHeight) { return; }

    const int2 blockOrigin = int2(gid) * int(MEMC_BLOCK_SIZE);
    half bestError = HALF_MAX;
    int2 bestVector = int2(0);

    #pragma unroll
    for (int vy = -MEMC_SEARCH_RADIUS; vy <= MEMC_SEARCH_RADIUS; vy++) {
        #pragma unroll
        for (int vx = -MEMC_SEARCH_RADIUS; vx <= MEMC_SEARCH_RADIUS; vx++) {
            half sad = 0.0h;

            #pragma unroll
            for (int by = 0; by < int(MEMC_BLOCK_SIZE); by++) {
                #pragma unroll
                for (int bx = 0; bx < int(MEMC_BLOCK_SIZE); bx++) {
                    int2 pA = blockOrigin + int2(bx, by);
                    int2 pB = pA + int2(vx, vy);

                    pA = clamp(pA, int2(0), int2(int(params.lowWidth) - 1, int(params.lowHeight) - 1));
                    pB = clamp(pB, int2(0), int2(int(params.lowWidth) - 1, int(params.lowHeight) - 1));

                    half a = lowA.read(uint2(pA)).r;
                    half b = lowB.read(uint2(pB)).r;
                    sad += abs(a - b);
                }
            }

            if (sad < bestError) {
                bestError = sad;
                bestVector = int2(vx, vy);
            }
        }
    }

    float2 fullResVector = float2(bestVector) * float(MEMC_DOWNSCALE);
    vectorOut.write(half4(half2(fullResVector), half(0.0), half(1.0)), gid);
}

static inline half2 medianVector3(half2 a, half2 b, half2 c) {
    half2 abMin = min(a, b);
    half2 abMax = max(a, b);
    return max(abMin, min(abMax, c));
}

kernel void memcFilterVectors(
    texture2d<half, access::read> vectorIn [[texture(0)]],
    texture2d<half, access::write> vectorOut [[texture(1)]],
    constant MEMCParams& params [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= params.vectorWidth || gid.y >= params.vectorHeight) { return; }

    int2 size = int2(int(params.vectorWidth), int(params.vectorHeight));
    int2 p = int2(gid);

    half2 center = vectorIn.read(uint2(p)).xy;
    half2 left = vectorIn.read(uint2(clamp(p + int2(-1, 0), int2(0), size - 1))).xy;
    half2 right = vectorIn.read(uint2(clamp(p + int2(1, 0), int2(0), size - 1))).xy;
    half2 up = vectorIn.read(uint2(clamp(p + int2(0, -1), int2(0), size - 1))).xy;
    half2 down = vectorIn.read(uint2(clamp(p + int2(0, 1), int2(0), size - 1))).xy;

    half2 horizontal = medianVector3(left, center, right);
    half2 vertical = medianVector3(up, center, down);
    half2 filtered = (horizontal + vertical) * half(0.5);

    half maxMotion = half(float(MEMC_SEARCH_RADIUS * MEMC_DOWNSCALE) * 1.25);
    filtered = clamp(filtered, half2(-maxMotion), half2(maxMotion));
    vectorOut.write(half4(filtered, half(0.0), half(1.0)), gid);
}

kernel void memcWarp(
    texture2d<float, access::sample> frameA [[texture(0)]],
    texture2d<float, access::sample> frameB [[texture(1)]],
    texture2d<half, access::sample> vectorMap [[texture(2)]],
    texture2d<float, access::write> output [[texture(3)]],
    constant MEMCParams& params [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]]
) {
    if (gid.x >= params.fullWidth || gid.y >= params.fullHeight) { return; }

    constexpr sampler linearSampler(coord::pixel, address::clamp_to_edge, filter::linear);

    float2 pos = float2(gid) + 0.5;
    float2 vectorCoord = pos / float(MEMC_DOWNSCALE * MEMC_BLOCK_SIZE);
    float2 motion = float2(vectorMap.sample(linearSampler, vectorCoord).xy);
    float2 leftMotion = float2(vectorMap.sample(linearSampler, vectorCoord + float2(-0.75, 0.0)).xy);
    float2 rightMotion = float2(vectorMap.sample(linearSampler, vectorCoord + float2(0.75, 0.0)).xy);
    float2 upMotion = float2(vectorMap.sample(linearSampler, vectorCoord + float2(0.0, -0.75)).xy);
    float2 downMotion = float2(vectorMap.sample(linearSampler, vectorCoord + float2(0.0, 0.75)).xy);

    float t = clamp(params.timestep, 0.0, 1.0);
    float2 sampleA = pos - motion * t;
    float2 sampleB = pos + motion * (1.0 - t);

    float4 colorA = frameA.sample(linearSampler, sampleA);
    float4 colorB = frameB.sample(linearSampler, sampleB);
    float4 originalA = frameA.sample(linearSampler, pos);
    float4 originalB = frameB.sample(linearSampler, pos);
    float4 linearBlend = mix(originalA, originalB, t);
    float4 warped = mix(colorA, colorB, t);

    float disagreement = distance(colorA.rgb, colorB.rgb);
    float confidence = 1.0 - smoothstep(params.occlusionThreshold * 0.55, params.occlusionThreshold, disagreement);
    float vectorJump = max(
        max(length(motion - leftMotion), length(motion - rightMotion)),
        max(length(motion - upMotion), length(motion - downMotion))
    );
    float vectorConfidence = 1.0 - smoothstep(6.0, 28.0, vectorJump);
    float sourceDelta = distance(originalA.rgb, originalB.rgb);
    float dissolveConfidence = 1.0 - smoothstep(0.32, 0.74, sourceDelta);
    float4 nearestBlend = mix(originalA, originalB, step(0.5, t));
    float4 safeBlend = mix(linearBlend, nearestBlend, (1.0 - dissolveConfidence) * 0.88);
    float edgeStep = max(1.0, min(2.0, float(MEMC_DOWNSCALE) * 0.5));
    float2 edgeX = float2(edgeStep, 0.0);
    float2 edgeY = float2(0.0, edgeStep);
    float edgeA = max(
        max(distance(originalA.rgb, frameA.sample(linearSampler, pos + edgeX).rgb),
            distance(originalA.rgb, frameA.sample(linearSampler, pos - edgeX).rgb)),
        max(distance(originalA.rgb, frameA.sample(linearSampler, pos + edgeY).rgb),
            distance(originalA.rgb, frameA.sample(linearSampler, pos - edgeY).rgb))
    );
    float edgeB = max(
        max(distance(originalB.rgb, frameB.sample(linearSampler, pos + edgeX).rgb),
            distance(originalB.rgb, frameB.sample(linearSampler, pos - edgeX).rgb)),
        max(distance(originalB.rgb, frameB.sample(linearSampler, pos + edgeY).rgb),
            distance(originalB.rgb, frameB.sample(linearSampler, pos - edgeY).rgb))
    );
    float hardEdgeConfidence = 1.0 - smoothstep(0.12, 0.34, max(edgeA, edgeB));

    // FIX: Reduced from 96px to 32px. The old 96px zone suppressed warping across
    // ~10% of the frame edges, pushing them to crossfade. 32px covers only the
    // outermost border pixels where motion vectors are least reliable.
    float edgeDistance = min(min(pos.x, float(params.fullWidth) - pos.x), min(pos.y, float(params.fullHeight) - pos.y));
    float edgeConfidence = smoothstep(0.0, 32.0, edgeDistance);
    float motionAmount = smoothstep(0.75, 6.0, length(motion));
    float stableWarp = confidence * vectorConfidence;
    float motionMix = mix(stableWarp * 0.35, stableWarp, motionAmount);
    float occlusionGuard = max(dissolveConfidence, 0.18);
    float hardEdgeGuard = mix(0.52, 1.0, hardEdgeConfidence);
    float finalMix = min(0.66, motionMix * edgeConfidence * occlusionGuard * hardEdgeGuard);

    output.write(mix(safeBlend, warped, finalMix), gid);
}
