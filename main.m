clc;clear; close all;
%% **************城市大气偏振模式模拟器***************************
% 本模拟器可以虚实融合地生成城市大气偏振模式，其包括：
%  1.在174幅mask中随机加载一幅mask
%  2.输入太阳位置（高度角和方位角），建立大气偏振半球模型
%  3.将大气偏振半球模型投影到1024*1224像素的图像上，并按照mask筛选


%% ***************参数输入***************************
%输入加载mask_mat的路径
mask_path = "./mask_mat/";
%输入生成的数据集保存的路径
image_path = "./test_dataset/images/";
label_path = "./test_dataset/labels/";

%输入相机内参
k1=0.02029;
k2=-0.00776;
k3=0.00235;
k4=-0.0006;
f_x=256.5099;
c_x=607.5547;
f_y=256.3968;
c_y=512.7949;

%% **************像素坐标系建立******************
row_num = 1024;  %行数
col_num = 1224;  %列数
row = linspace(1, 1024, row_num);  
col = linspace(1,1224, col_num);

% 建立网格;
[col,row]=meshgrid(col,row);
u = col;
v = 1025 - row;

%% ***********坐标转换******************
%%像素坐标系转换到图像坐标系
x_d = (u - c_x) / f_x;
y_d = (v - c_y) / f_y;
z_d = ones(size(x_d));
%%图像坐标系转换到天球坐标系(球坐标)
p1 = (sign(x_d)+1)/2;
p2 = 1-p1;
p3 = (sign(y_d)+1)/2;
p4 = 1-p3;
psi = p1.*p3.*atan(y_d./x_d) + p1.*p4.*(atan(y_d./x_d)+2*pi) + p2.*(atan(y_d./x_d)+pi);
theta_d = (x_d.^2+y_d.^2).^0.5;
theta = theta_d;

% 球坐标转换为直角坐标
% x_mm=sin(theta).*cos(psi)*1;           % x in transformational relation;
% y_mm=sin(theta).*sin(psi)*1;           % y in transformational relation;
% z_mm=cos(theta);  

%% ***********大气偏振模式生成******************
for data_num = 1:3000
	psi_sd = rand()*359;
	theta_sd = rand()*90;
    psi_s = deg2rad(psi_sd);
    theta_s = deg2rad(theta_sd);
	psi_s_label = round(psi_sd);
    %%计算AOP    
    t1=sin(theta)*cos(theta_s)-cos(theta)*sin(theta_s).*cos(-psi_s+psi);
    t2=sin(theta_s).*sin(psi_s-psi);
    AOP=atand(t1./t2);
    %%计算DOP 
    b=cos(theta)*cos(theta_s)+sin(theta)*sin(theta_s).*cos(abs(psi-psi_s));  %计算b为cos（gamma＿
    DOP=(1-b.^2)./(1+b.^2);

    %画3D半球模型
    % figure('Renderer','zbuffer','Color',[1 1 1]);
    % surf(x_mm,y_mm,z_mm,AOP);
    % shading interp;
    % colorbar('westoutside');
    % view(-63.5,36);
    % zlim([0,1]);
    % xlabel('x_axis'),ylabel('y_axis'),zlabel('z_axis');

    %显示
    % figure();
    % pic = mat2rgb(AOP,jet);
    % imshow(pic)
    % figure();
    % pic = mat2rgb(DOP);
    % imshow(pic)

    %%随机加载一幅Mask
    mask_num = randi(174);
    load(strcat(mask_path,num2str(mask_num),'.mat'),'mask');
    mask_matrix = mask;

    %%将mask覆盖到AOP表面
    [m,n] = size(AOP);
    AOP_crop = ones([m,n]);
    for i=1:m
        for j=1:n
            if mask_matrix(i,j) == 0
                AOP_crop(i,j) = NaN;
            else
                AOP_crop(i,j) = AOP(i,j);
            end
        end
    end
    % 输出图像为jpg
    AOP_crop_img = mat2rgb(AOP_crop, jet);
    imwrite(AOP_crop_img, strcat(image_path,num2str(data_num),'_p',num2str(psi_s_label),'m',num2str(mask_num),'.jpg'));
    % 在txt文档中打印theta_s为label
    fid = fopen(strcat(label_path,num2str(data_num),'_p',num2str(psi_s_label),'m',num2str(mask_num),'.txt'), 'w');
    fprintf(fid, '%d', psi_s_label);        
    status = fclose(fid);
    close all;
    % data_num 加一
    data_num = data_num+1;
   



            
             






end

