cover='cover.jpg';
stego='stegojsteg.jpg';

try 
    jobj=jpeg_read(cover);
    dct=jobj.coef_arrays{1};
    dct1=jobj.coef_arrays{1};
catch
    error('Error(problem with the cover image)');
end
insertable = dct ~= 0 & dct ~= 1;
insertable(1:8:end, 1:8:end) = false;
AC=sum(insertable(:));%��Ƕ���ݵ�ACϵ������



wen.txt_id=fopen('hide.txt','r');%���ص���Ϣ
[msg,L]=fread(wen.txt_id,'ubit1');
if(length(msg)>AC)
    error('ERROR(too long message)');
end
msg=round(rand(AC,1));

len=length(msg);
id=1;
[m,n]=size(dct);
for f2 =1:n
    for f1 =1:m
        if(dct(f1,f2) == 0)
            continue;
        end
        if((dct(f1,f2) == 1)&&msg(id,1)==0)%dctΪ1��Ƕ������Ϊ0��dct��0������Ƕ��
            dct(f1,f2)=0;
            continue;
        end
        if((dct(f1,f2) == 1)&&msg(id,1)==1)
            dct(f1,f2)=dct(f1,f2);
        end
        if((dct(f1,f2) == -1)&&msg(id,1)==0)%dctΪ-1��Ƕ������Ϊ0��dct��0������Ƕ��
            dct(f1,f2)=0;
            continue;
        end
        if((dct(f1,f2) == -1)&&msg(id,1)==1)
            dct(f1,f2)=dct(f1,f2);
        end
        if(dct(f1,f2)>1)%dctϵ������1
            odd=mod(dct(f1,f2),2);
            if(msg(id,1)==0&&odd==1)%Ƕ����ϢΪ0��ACϵ��Ϊ����
                dct(f1,f2)=dct(f1,f2)-1;
            end
            if(msg(id,1)==1 && odd==0)%Ƕ����ϢΪ1��ACϵ��Ϊż��
               dct(f1,f2)=dct(f1,f2)-1;
            end
        end
        if(dct(f1,f2)<-1)%dctϵ��С��0
            odd=abs(mod(dct(f1,f2),2));
            if(msg(id,1)==0&&odd==1)%Ƕ����ϢΪ0��ACϵ��Ϊ����
                dct(f1,f2)=dct(f1,f2)+1;
            end
            if(msg(id,1)==1 && odd==0)%Ƕ����ϢΪ1��ACϵ��Ϊż��
               dct(f1,f2)=dct(f1,f2)+1;
            end
        end
        if(id==len)
            break;
        end
        id=id+1;
    end
    if id ==len
        break;
    end
end

    
try 
    jobj.coef_arrays{1}=dct;
    jobj.optimize_coding=1;
    jpeg_write(jobj,stego);
catch
    error('ERROR (problem with saving the stego image)')
end

subplot(2,2,1);
imshow(cover);
title('initial image');
subplot(2,2,2);
imshow(stego);
title('after image');
subplot(2,2,3);
histogram(dct1, 300);
axis([-16 16,0 2e4]);
title('histogram of initial image');
subplot(2,2,4);
histogram(dct,300);
axis([-16 16,0 2e4]);
title('histogram of after image');
            
            
            
        
            
            
        
            
            
            
        
    
