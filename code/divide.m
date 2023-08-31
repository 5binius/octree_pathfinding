function [out]=divide(out,im,z1,y1, x1, length)

 fprintf("z=%d y= %d x= %d length= %d\n",z1,y1,x1,length);
flag=1;

if length==1
    out(z1,y1,x1)=1;
    fprintf("length 1 %d \n",out(z1,y1,x1));
    return;
    
else if length>1

 for e=z1:z1+length-1
 for d=y1:y1+length-1
    for c=x1:x1+length-1

        fprintf("%d %d %d\n",e,d,c);
        if im(e,d,c)~=0
            
            fprintf("split\n");
         out=   divide(out,im,z1,y1,x1,length/2);
         out = divide(out,im,z1,y1+length/2,x1,length/2);
         out =  divide(out,im,z1,y1,x1+length/2,length/2);
         out =  divide(out,im,z1,y1+length/2,x1+length/2,length/2);
         
          out=   divide(out,im,z1+length/2,y1,x1,length/2);
         out = divide(out,im,z1+length/2,y1+length/2,x1,length/2);
         out =  divide(out,im,z1+length/2,y1,x1+length/2,length/2);
         out =  divide(out,im,z1+length/2,y1+length/2,x1+length/2,length/2);
            flag=0;
            break;
        end
    end
    if flag==0
        break;
    end
 end
  if flag==0
        break;
    end
 end
 if flag==1
 out(z1,y1,x1)=length;
fprintf("%d \n",out(z1,y1,x1));
return;
end

end

end

