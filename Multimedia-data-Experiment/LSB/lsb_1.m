clc;
clear;
%读取原始图像并转换为double类型
source_data1=imread('test.jpeg');
source_data = rgb2gray(source_data1);
d_a=double(source_data);

%打印原始图像
subplot(2,2,1); 
a=uint8(d_a);
imshow(a);

%设置秘密信息载体
d_a_0=bitand(d_a,1);
d_a_1_7=bitand(d_a,254);

%读取秘密信息
fr = fopen('load.jpeg','r');
[r1,len] = fread(fr,'ubit1');
%将秘密信息导入载体
for i=1:len
    d_a_0(i)=r1(i);
end

%将载体替换原始图像中的信息
d_b=bitor(d_a_1_7,d_a_0);

%打印更改后的图像
subplot(2,2,2); 
b=uint8(d_b);
imshow(b);

%打印直方图
count_1=imhist(a);
subplot(2,2,3);
stem(2:15,count_1(3:16));
count_2=imhist(b);
subplot(2,2,4);
stem(2:15,count_2(3:16));

%信息提取检查
d_b_0=bitand(d_b,1);
mes_2=zeros(len,1);
for i=1:len
    mes_2(i)=d_b_0(i);
end