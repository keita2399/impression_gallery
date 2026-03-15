#version 460 core

precision mediump float;

#include <flutter/runtime_effect.glsl>

// Uniforms
uniform vec2 uSize;          // Canvas size (float index 0,1)
uniform vec2 uLightPos;      // Light position 0.0~1.0 (float index 2,3)
uniform float uLightRadius;  // Light reach radius (float index 4)
uniform float uAmbient;      // Ambient light strength (float index 5)
uniform float uIntensity;    // Highlight intensity (float index 6)
uniform vec3 uLightColor;    // Light color RGB (float index 7,8,9)
uniform sampler2D uTexture;  // Painting texture (sampler index 0)

out vec4 fragColor;

void main() {
    vec2 fragCoord = FlutterFragCoord().xy;
    vec2 uv = fragCoord / uSize;

    // Sample texture color
    vec4 texColor = texture(uTexture, uv);

    // Distance from light source
    vec2 lightDir = uv - uLightPos;
    lightDir.x *= uSize.x / uSize.y; // Aspect ratio correction
    float dist = length(lightDir);

    // Smooth light falloff
    float attenuation = 1.0 - smoothstep(0.0, uLightRadius, dist);

    // Final brightness = ambient + light intensity * falloff
    float brightness = uAmbient + uIntensity * attenuation;

    // Apply light color
    vec3 litColor = texColor.rgb * brightness * uLightColor;

    // Specular highlight (glossy feel)
    float specular = pow(attenuation, 4.0) * 0.15;
    litColor += specular * uLightColor;

    fragColor = vec4(litColor, texColor.a);
}
