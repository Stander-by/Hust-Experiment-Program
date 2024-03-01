cover='cover.jpg';
stego='stegojsteg.jpg';
frr=fopen('dec.txt','w');
try 
    jobj=jpeg_read(stego);
    dct=jobj.coef_arrays{1};
    dct1=jobj.coef_arrays{1};
catch
    error('Error(problem with the cover image)');
end
len=1200;
p=1;
[m,n]=size(dct);
for f2 =1:n
    for f1 =1:m
        if(dct(f1,f2)==1||dct(f1,f2)==0)
            continue;
        end
        
        odd=mod(dct(f1,f2),2);
        fwrite(frr,odd,'ubit1');
        
        
        if(p==len)
            break;
        end
        p=p+1;
        
    end
    if p ==len
        break;
    end
end
fclose(frr);
            
            
        
            
            
        
            
            
            
        
    
