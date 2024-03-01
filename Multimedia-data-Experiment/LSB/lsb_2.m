clc;
clear;
%��ȡԭʼͼ��ת��Ϊdouble����
image1=imread('test.jpeg');
source_data=rgb2gray(image1);
d_a=double(source_data);

%��ӡԭʼͼ��
subplot(2,2,1); 
a=uint8(d_a);
imshow(a);

%����������Ϣ����
d_a_0=bitand(d_a,1);
d_a_1_7=bitand(d_a,254);


%��ȡ������Ϣ
fr = fopen('load.jpeg','r');
[r1,len] = fread(fr,'ubit1');
%��������Ϣ��������
rng(1,'twister');
r2=randi(len,len,1);
for i=1:len
    k=r2(i);
    d_a_0(k)=r1(i);
end

%�������滻ԭʼͼ���е���Ϣ
d_b=bitor(d_a_1_7,d_a_0);

%��ӡ���ĺ��ͼ��
subplot(2,2,2); 
b=uint8(d_b);
imshow(b);

%��ӡֱ��ͼ
count_1=imhist(a);
subplot(2,2,3);
stem(2:15,count_1(3:16));
count_2=imhist(b);
subplot(2,2,4);
stem(2:15,count_2(3:16));

