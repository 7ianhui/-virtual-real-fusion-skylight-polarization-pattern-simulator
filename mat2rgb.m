function imgRGB = mat2rgb(Matrix,colorType)
%% 作者：陶鑫
%% 版本：v1.0.0.0
%% 时间：2021.06.04 12:12
%%
%% 使用方法
% >> imgRGB = mat2rgb(Matrix,colorType)
% 其中：
% >> imgRGB 为输出的彩色图像
% >> Matrix 为输入矩阵
% >> colorType为颜色方案(可选)，缺省时为parula
% 建议颜色方案有：
% parula
% jet
% hsv
% hot
% cool
% sprint
% summer
% autumn
% winter

%% 默认用jet配色
if nargin == 1
    colorType = parula;
end
%% 矩阵归一化
imgStd = (Matrix - min(min(Matrix)))/(max(max(Matrix))-min(min(Matrix)));
%% 矩阵转为8位图像作为索引图
temp = im2uint8(imgStd);
%% 按colorType选择颜色
imgRGB = ind2rgb(temp,colorType);
%% 修正NAN的值，将NAN的值置为白色
imgR=imgRGB(:,:,1);
imgR(isnan(Matrix))=1;
imgRGB(:,:,1)=imgR;
imgG=imgRGB(:,:,2);
imgG(isnan(Matrix))=1;
imgRGB(:,:,2)=imgG;
imgB=imgRGB(:,:,3);
imgB(isnan(Matrix))=1;
imgRGB(:,:,3)=imgB;
end