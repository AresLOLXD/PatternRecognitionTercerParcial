
clear all;
clc
archivo="Bases Sossa";
grupoImagenes={};
valoresImagenes=[];
CONST=20;
for i=1:120
    if(isfile(strcat(archivo,"/IMAG",addZeros(i),".BMP")))
        imagen=imread(strcat(archivo,"/IMAG",addZeros(i),".BMP"));
        imagenBW=imdilate(im2bw(imagen),strel("disk",1));
        s=regionprops(imagenBW,"Area","Perimeter","BoundingBox");
        imshow(imagenBW);
        for j=1:length(s)
            figura=s(j);
            cociente=figura.Area/(figura.Perimeter^2);
            inicioX=floor(figura.BoundingBox(1));
            inicioY=floor(figura.BoundingBox(2));
            copiaImagen=[];

            for k=inicioX-CONST:ceil(inicioX+figura.BoundingBox(3)+CONST)
                for m=inicioY-CONST/2:ceil(inicioY+figura.BoundingBox(4)+CONST/2)
                    copiaImagen(m-inicioY+CONST/2+1,k-inicioX+CONST+1)=imagen(m,k);
                end
            end
            figure(1);
            imshow(imagen);
            hold on;
            rectangle("Position",[figura.BoundingBox(1) figura.BoundingBox(2) figura.BoundingBox(3) figura.BoundingBox(4)],"EdgeColor",[0 1 0], "LineWidth",1)
            
            figure(2)
            imshow(uint8(copiaImagen));
            hold on;
            
            indice=input("Que tipo de figura es: ");
            if(indice>length(valoresImagenes))
                valoresImagenes(end+1)=cociente;
                indice=length(valoresImagenes);
                grupoImagenes{indice}={};
            end
            
            
            
            grupoImagenes{indice}{end+1}=copiaImagen;
        end
    end
end
disp("Alv");
function cadena=addZeros(valor)
if(valor<10)
    cadena=strcat("00",int2str(valor));
elseif(valor<100)
    cadena=strcat("0",int2str(valor));
else
    cadena=strcat("",int2str(valor));
end
end

