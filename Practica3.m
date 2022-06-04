clc
clear all
close all
warning off all
global movimientos;
global mapaMarcados;
global alto;
global ancho;
movimientos=[
     0 0 -1 1  1 1 -1 -1;
    -1 1  0 0 -1 1  1 -1
];


figure(1)
subplot(3,1,1)
imagen=imread("Figuras.bmp");
imshow(imagen);
title('Original')
subplot(3,1,2)
global imagenBW;
imagenBW=not(im2bw(imagen, 0.999));
imshow(imagenBW);
title("Blanco y negro");
imagenBW=imagenBW;
dimensiones=size(imagen,1,2);

alto=dimensiones(1);
ancho=dimensiones(2);

mapaMarcados=zeros(alto,ancho);
contador=0;
for i=1:alto
    for j=1:ancho
        if(imagenBW(i,j) && mapaMarcados(i,j)==0)
            busqueda(contador+1,i,j);
            contador=contador+1;
        end
    end
end
colores=floor(hsv(contador)*256);
subplot(3,1,3)
imagenColoreada=zeros(alto,ancho,3);
imagenColoreada(:,:,:)=256;

for i=1:alto
    for j=1:ancho
        if(mapaMarcados(i,j)~=0)
            imagenColoreada(i,j,:)=colores(mapaMarcados(i,j),:);
        end
    end
end
imagenColoreada=uint8(imagenColoreada);
imshow(imagenColoreada);
title("Figuras coloreadas")
fprintf("Se encontraron %d figuras\n",contador)

formas={};          % separar figuras para identificar forma
for i=1:contador
    [row,col]=find(mapaMarcados==i);
    formas{end+1}=mapaMarcados(min(row):max(row),min(col):max(col));
    [row,col] = find(formas{end}~=i);   % filtrar
    for j=1:length(row)
        formas{end}(row(j),col(j)) = 0;
    end
end

function busqueda(color,posY,posX)
    global mapaMarcados;
    global imagenBW;
    global movimientos;
    global ancho;
    global alto;
    if(posX<1 || posY<1 || posX>ancho || posY>alto||mapaMarcados(posY,posX)~=0||~imagenBW(posY,posX))
        return;
    end
    for i=1:length(movimientos)
        movimiento=movimientos(:,i);
        mapaMarcados(posY,posX)=color;
        busqueda(color,posY+movimiento(1),posX+movimiento(2));
    end
end
