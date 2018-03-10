# NormalMapping

OpenGL中法线贴图的运用，增强细节

## 依赖
* glfw3.lib 推荐在[官方网站](http://www.glfw.org/download.html)下载源代码，然后自行编译。本项目编译使用的是CMake和Visual Studio 2015.
* GLAD 打开GLAD的[在线服务](http://glad.dav1d.de/)可轻松配置。本项目使用OpenGL 4.3.
* stb_image.h 是[Sean Barrett](https://github.com/nothings)的一个非常流行的单头文件图像加载库，可以在[这里](https://github.com/nothings/stb/blob/master/stb_image.h)下载。本项目使用其来加载纹理图片。
* GLM 一个只有头文件的库，不用链接和编译。可以在它们的[网站](http://glm.g-truc.net/0.9.5/index.html)上下载。本项目使用其作为数学库。
* Assimp 一个非常流行的模型导入库，可以在[下载页面](http://assimp.org/main_downloads.html)选择相应的版本，自行使用CMake 和 Visual Studio 2015编译。

## 思路
使用一个2D纹理来储存法线数据。2D纹理不仅可以储存颜色和光照数据，还可以储存法线向量。这样可以从2D纹理中采样得到特定纹理的法线向量。

## 实现步骤

1. 通过纹理坐标计算出切线和副切线向量，求出TBN矩阵

2. 有两种方式实现TBN矩阵

	1. 直接使用TBN矩阵，这个矩阵可以把切线坐标空间的向量转换到世界坐标空间。因此把它传给片段着色器，把通过采样得到的法线坐标左乘上TBN矩阵，转换到世界坐标空间中，这样所有法线和其他光照变量就在同一个坐标系中了。
	
	2. 也可以使用TBN矩阵的逆矩阵，这个矩阵可以把世界坐标空间的向量转换到切线坐标空间。因此使用这个矩阵左乘其他光照变量，把他们转换到切线空间，这样法线和其他光照变量再一次在一个坐标系中了。

3. 通过计算出的法线量来计算光照

一般来说，法线贴图和高度贴图（之后会涉及到）结合使用效果最好，所以通常会使用第二种方法，即在切线空间中计算光照

## 改进

当在更大的网格上计算切线向量的时候，它们往往有很大数量的共享顶点，当发下贴图应用到这些表面时将切线向量平均化通常能获得更好更平滑的结果。这样做有个问题，就是TBN向量可能会不能互相垂直，这意味着TBN矩阵不再是正交矩阵了。法线贴图可能会稍稍偏移，但这仍然可以改进。

使用叫做 **格拉姆-施密特正交化过程（Gram-Schmidt process）** 的数学技巧，可以对TBN向量进行重正交化，这样每个向量就又会重新垂直了。

```
vec3 T = normalize(vec3(model * vec4(tangent, 0.0)));
vec3 N = normalize(vec3(model * vec4(normal, 0.0)));

T = normalize(T - dot(T, N) * N);

vec3 B = cross(T, N);

mat3 TBN = mat3(T, B, N)
```

这样稍微花费一些性能开销就能对法线贴图进行一点提升。

## 效果

- 法线贴图

![法线贴图](https://github.com/SweeneyChoi/NormalMapping/blob/master/images/normalmapping1.png)

- 给复杂模型添加法线贴图

![复杂模型](https://github.com/SweeneyChoi/NormalMapping/blob/master/images/normalmapping2.png)



