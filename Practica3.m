clc
clear all
close all
warning off all
format short;
global movimientos;
global mapaMarcados;
global alto;
global ancho;
global position;

global formas;
global imagenColoreada;

global M00 M10 M01 M11 M20 M02 M30 M03 M12 M21;

global m00 m01 m10 m11 m20 m02 m21 m12 m30 m03 n11 n12 n02 n20 n21 n03 n30;

global hu;
movimientos=[
     0 0 -1 1  1 1 -1 -1;
    -1 1  0 0 -1 1  1 -1
];

diccionario_hu={
{'Circulo',[    0.159155950125469,   0,                   0,                   0,                   0,                   0,                    0]},
{'Triangulo',[  0.194844421004016,   0.000852606338626,   0.033025253276506,   0.005077149142085,   0.000060312324868,   0.000013832097450,   -0.007562986555972]},
{'Corazon',[    0.185494752865170,   0.002844914796864,   0.119645081542564,   0.011990439545155,   0.000445174096434,  -0.000049245492345,   -0.017662017812297 ]},
{'Estrella',[   0.216740624973792,   0.000326093386463,   0.043811033690056,   0.004840943130283,   0.000070489440657,  -0.000002450833026,   -0.007244366317560]},
{'Cuadrado',[   0.166659259259259,   0,                   0,                   0,                   0,                   0,                    0]},
};

%diccionario_hu={
%    {'Estrella',[0.2003    0.0002    0.0035    0.0004    0.0000   -0.0000   -0.0006]},
%    {'Circulo',[0.1594    0.0001    0.0026    0.0003    0.0000    0.0000   -0.0004]},
%    {'Circulo',[0.1592    0.0000    0.0007    0.0001    0.0000   -0.0000   -0.0001]},
%    {'Rectangulo',[0.1766    0.0034    0.0627    0.0070    0.0001         0   -0.0104]},
%    {'Circulo',[0.1592    0.0000    0.0005    0.0001    0.0000   -0.0000   -0.0001]},
%    {'Triangulo',[0.1925    0.0013    0.3292    0.0293    0.0029   -0.0001   -0.0425]},
%    {'Corazon',[0.1726    0.0015    0.0557    0.0056    0.0001   -0.0000   -0.0084 ]},
%    {'Rectangulo',[0.2071    0.0151    0.2570    0.0286    0.0024         0   -0.0416]},
%    {'Estrella',[0.2170    0.0045    0.5242    0.0582    0.0102   -0.0000   -0.0822]},
%    {'Corazon',[0.1705    0.0009    0.0377    0.0037    0.0000   -0.0000   -0.0055]},
%    {'Cuadro',[0.1669    0.0001    0.0017    0.0002    0.0000         0   -0.0003]},
%};

figure(1)
subplot(1,2,1)
imagen=imread("Figuras3.png");
imshow(imagen);
title('Original')
subplot(1,2,2)
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
figure(2)
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

separar(mapaMarcados,contador)

for i=1:contador
    min_distance = 1;
    raw_moments(formas{i})
    central_moments()
    invariants_nij()
    hu_moments()
    nombre='';
    for j=1:size(diccionario_hu,1)
        %aux = norm(hu-diccionario_hu{j}{2});
        aux = norm(hu([1:2,4:end])-diccionario_hu{j}{2}([1:2,4:end]));
        if aux<min_distance
            min_distance = aux;
            nombre = diccionario_hu{j}{1};
        end
    end
    if(min_distance<1)
        fprintf('%d %s\n',i,nombre);
        pos = [position{i}(1)-10 position{i}(2)];
        imagenColoreada = insertText(imagenColoreada,pos,nombre);
    else
        fprintf('%d %s\n',i,"Desconocido");
        pos = [position{i}(1)-10 position{i}(2)];
        imagenColoreada = insertText(imagenColoreada,pos,"Desconocido");
    end
end
imshow(imagenColoreada)

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

function separar(matrix,contador)
    global imagenColoreada;
    global formas;
    global position;
    formas={};          % separar figuras para identificar forma
    for i=1:contador
        [row,col]=find(matrix==i);
        imagenColoreada = insertText(imagenColoreada,[min(col),min(row)],int2str(i));
        position{end+1} = [mean(col) mean(row)];
        formas{end+1}=matrix(min(row):max(row),min(col):max(col));
        [row,col] = find(formas{end}~=i);   % filtrar
        for j=1:length(row)
            formas{end}(row(j),col(j)) = 0;
        end
        [row,col] = find(formas{end}==i);   % black and whitefor
        for j=1:length(row)
            formas{end}(row(j),col(j)) = 1;
        end
    end
end

function raw_moments(forma)
    global formas;

    global M00 M10 M01 M11 M20 M02 M30 M03 M12 M21;

    M00=sum(forma(:));

    M10=0;
    for i=1:size(forma,2)
        M10 = M10 + i * sum(forma(:,i));
    end

    M01=0;
    for i=1:size(forma,1)
        M01 = M01 + i * sum(forma(i,:));
    end

    M11=0;
    for i=1:size(forma,1)
        for j=1:size(forma,2)
            M11 = M11 + j*i*forma(i,j);
        end
    end

    M20=0;
    for i=1:size(forma,2)
        M20 = M20 + i^2 * sum(forma(:,i));
    end

    M02=0;
    for i=1:size(forma,1)
        M02 = M02 + i^2 * sum(forma(i,:));
    end

    M30=0;
    for i=1:size(forma,2)
        M30 = M30 + i^3 * sum(forma(:,i));
    end

    M03=0;
    for i=1:size(forma,1)
        M03 = M03 + i^3 * sum(forma(i,:));
    end

    M12=0;
    for i=1:size(forma,1)
        for j=1:size(forma,2)
            M12 = M12 + i*j^2*forma(i,j);
        end
    end

    M21=0;
    for i=1:size(forma,1)
        for j=1:size(forma,2)
            M21 = M21 + i^2*j*forma(i,j);
        end
    end
end

function central_moments()
    global M00 M10 M01 M11 M20 M02 M30 M03 M12 M21;

    global m00 m01 m10 m11 m20 m02 m21 m12 m30 m03;

    x=M10/M00; %centroides
    y=M01/M00;

    m00=M00;
    m01=0;
    m10=0;
    m11=M11-x*M01;
    m20=M20-x*M10;
    m02=M02-y*M01;
    m21=M21-2*x*M11-y*M20+2*x^2*M01;
    m12=M12-2*y*M11-x*M02+2*y^2*M10;
    m30=M30-3*x*M20+2*x^2*M10;
    m03=M03-3*y*M02+2*y^2*M01;
end

function invariants_nij()
    global m00 m11 m20 m02 m21 m12 m30 m03;

    global n11 n12 n02 n20 n21 n03 n30;

    n11=m11/m00^(1+(1+1)/2);
    n12=m12/m00^(1+(1+2)/2);
    n02=m02/m00^(1+(0+2)/2);
    n20=m20/m00^(1+(2+0)/2);
    n21=m21/m00^(1+(2+1)/2);
    n03=m03/m00^(1+(0+3)/2);
    n30=m30/m00^(1+(3+0)/2);

end

function hu_moments()
    global n11 n12 n02 n20 n21 n03 n30;

    global hu;

    I1=n20+n02;
    I2=(n20-n02)^2+4*n11^2;
    I3=(n30-3*n12)^2+(3*n21-n03)^2;
    I4=(n30+n12)^2+(n21+n03)^2;
    I5=(n30-3*n12)*(n30+n12)*((n30+n12)^2-3*(n21+n03)^2)+(3*n21-n03)*(n21+n03)*(3*(n30+n12)^2-(n21+n03)^2);
    I6=(n20-n02)*((n30+n12)^2-(n21+n03)^2)+4*n11*(n30+n12)*(n21+n03);
    I7=(3*n21-n03)*(n30+n12)*((n30+n12)^2-3*(n21+n03)^2)-(n30-3*n12)*(n21+n03);
    
    hu=[I1,I2,I3,I4,I5,I6,I7];
end
