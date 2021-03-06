#version 430 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec2 aTexCoords;
layout (location = 3) in vec3 aTangent;
layout (location = 4) in vec3 aBitangent;

out vec3 FragPos;
out vec2 TexCoords;
out mat3 TBN;

uniform mat4 projection;
uniform mat4 view;
uniform mat4 model;


void main()
{
	mat3 normalMatrix = mat3(transpose(inverse(model)));
	vec3 T = normalize(normalMatrix * aTangent);
	vec3 B = normalize(normalMatrix * aBitangent);
	vec3 N = normalize(normalMatrix * aNormal);
	T = normalize(T - dot(T, N) * N);
	B = cross(T, N);
	TBN = mat3(T, B, N);

	FragPos = vec3(model * vec4(aPos, 1.0));
    TexCoords = aTexCoords;    
	gl_Position = projection * view * vec4(FragPos, 1.0);
}