clc;
clear;
%��ȡԭʼͼ��ת��Ϊdouble����
source_data1=imread('test.jpeg');
source_data = rgb2gray(source_data1);
d_a=double(source_data);

%��ӡԭʼͼ��
subplot(2,2,1); 
a=uint8(d_a);
imshow(a);

%����������Ϣ����
d_a_0=bitand(d_a,1);
d_a_1_7=bitand(d_a,254);

% %��ȡ������Ϣ
fr = fopen('load.jpeg','r');
[r1,len] = fread(fr,'ubit1');
% r1=randi(2,656,562);
% len = 656*562-1;
%��������Ϣ��������
for i=1:len
    d_a_0(i)=r1(i);
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

r=0;
for i=0:127
    k=2*i+1;
    m=k+1;
    r=r+(count_2(k)-count_2(m))*(count_2(k)-count_2(m))/(2.0*(count_2(k)+count_2(m)));
end
p=1-chi2cdf(r,127)