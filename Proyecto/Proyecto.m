clc
clear all
close all
warning off all

rutaBase  = "Bases Sossa\";
archivos = dir(strcat(rutaBase , "*.BMP"));
clases = {[], [], [], [], []};
imagenes = {[], [], [], [], []};
medias = {};
cantidades = [];

for i = 1:length(archivos)
    [clases, imagenes, cantidad] = generaClases(strcat(rutaBase ,archivos(i).name), archivos(i).name, clases, imagenes);
    cantidades = [cantidades; cantidad];
end

for i = 1:5
    medias{i} = mean(clases{i});
end

[archivoPrueba, rutaArchivoPrueba] = uigetfile('*.png;*.jpg;*.webp;*.svg;*.bmp','Archivos de imagen');
cantidadResultados=input("Ingresa la cantidad de resultados posibles: ");
analizaImagen(strcat(rutaArchivoPrueba  , archivoPrueba),  medias, cantidades,cantidadResultados);


fprintf("Proceso terminado\n")

function [clases, imagenes, cantidad] = generaClases(rutaArchivo, nombreArchivo, clases, imagenes)
imagenTrain = imread(rutaArchivo);
imagenTrain = imresize(imagenTrain, 2);

se = offsetstrel('ball', 3, 1, 4);
imagenTrain = imdilate(imagenTrain, se);
imagenTrain = imbinarize(imagenTrain);

objetos=regionprops(imagenTrain, 'Centroid', 'BoundingBox', 'Circularity', 'Area', 'Perimeter', 'Eccentricity', 'Extent', 'Orientation');

rondanas = 0;
llaves = 0;
colaDePatos = 0;
tornillos = 0;
armella = 0;

for i=1:length(objetos)
    objeto = objetos(i);
    rectangulo = objeto.BoundingBox;

    if(objeto.Area <= 300)
        continue
    end

    try
        cociente = (objeto.Perimeter^2)/objeto.Area;
        elem = [cociente objeto.Extent objeto.Circularity objeto.Orientation objeto.Eccentricity];
        elemImagen = {rutaArchivo, nombreArchivo, rectangulo};

        if (cociente > 54)
            llaves = llaves + 1;
            clases{1} = [clases{1}; elem];
            imagenes{1} = [imagenes{1}; elemImagen];
        elseif (cociente > 33)
            armella = armella + 1;
            clases{2} = [clases{2}; elem];
            imagenes{2} = [imagenes{2}; elemImagen];
        elseif (cociente > 24)
            tornillos = tornillos + 1;
            clases{3} = [clases{3}; elem];
            imagenes{3} = [imagenes{3}; elemImagen];
        elseif (cociente > 16)
            colaDePatos = colaDePatos + 1;
            clases{4} = [clases{4}; elem];
            imagenes{4} = [imagenes{4}; elemImagen];
        elseif (cociente > 11)
            rondanas = rondanas + 1;
            clases{5} = [clases{5}; elem];
            imagenes{5} = [imagenes{5}; elemImagen];
        end

    catch error
        disp(error);
    end
end

cantidad = {llaves,armella,tornillos,colaDePatos,rondanas,rutaArchivo};
end

function analizaImagen(rutaArchivo,  medias, cantidades,cantidadResultados)
imagenTest = imread(rutaArchivo);
imagenTest = imresize(imagenTest, 2);

figure(1);
imshow(imagenTest);

se = offsetstrel('ball', 3, 1, 4);
imagenTest = imdilate(imagenTest, se);
c = imbinarize(imagenTest);

objetos=regionprops(c, 'Centroid', 'BoundingBox', 'Circularity', 'Area', 'Perimeter', 'Eccentricity', 'Extent' ,'Orientation');

rondanas = 0;
llaves = 0;
colasDePato = 0;
tornillos = 0;
armella = 0;

for i=1:length(objetos)
    figure(1);
    objeto = objetos(i);
    rectangulo = objeto.BoundingBox;

    if(objeto.Area > 300)
        rectangle("Position",[rectangulo(1),rectangulo(2),rectangulo(3),rectangulo(4)],'Edgecolor','r','Linewidth',1);
    else
        continue
    end

    cociente = (objeto.Perimeter^2)/objeto.Area;
    elem = [cociente objeto.Extent objeto.Circularity objeto.Orientation objeto.Eccentricity];
    labelFigura = "";
    clase = distanciaEuclideana(elem, medias);

    switch clase
        case 1
            llaves = llaves + 1;
            labelFigura = "Alcayata";
        case 2
            armella = armella + 1;
            labelFigura = "Armella";
        case 3
            tornillos = tornillos + 1;
            labelFigura = "Tornillo";
        case 4
            colasDePato = colasDePato + 1;
            labelFigura = "Cola de pato";
        case 5
            rondanas = rondanas + 1;
            labelFigura = "Rondana";
        otherwise
            labelFigura = "Desconocido";
    end

    text(objeto.Centroid(1), objeto.Centroid(2), labelFigura,'Color','g','FontWeight','bold','FontName',"Times");
end

elem = [llaves armella tornillos colasDePato rondanas];

elemsPrueba = {};
for i = 1:length(cantidades)
    cantidad = cantidades(i, :);
    elemsPrueba{i} = [cantidad{1} cantidad{2} cantidad{3} cantidad{4} cantidad{5}];
end

for i = 1:cantidadResultados
    indice = distanciaEuclideana2(elem, elemsPrueba);
    cantidad = cantidades(indice, :);
    elemsPrueba{indice} = [1000 1000 1000 1000 1000];

    figure(2)
    subplot(1, cantidadResultados , i);
    imagen = imread(cantidad{6});
    imagen = imresize(imagen, 2);

    imshow(imagen);
    title("Imagenes parecida");

end

end


% Funcion para el criterio por distancia euclideana
function numClase = distanciaEuclideana2(x, medias)
distancias = zeros(1,length(medias));
for i = 1:length(medias)
    % Se almacenan la distancia
    % de la media i al vector desonocido
    % x
    distancias(i) = norm(medias{i} - x);
end

[~ , numClase] = min(distancias);
end

% Funcion para el criterio por distancia euclideana
function numClase = distanciaEuclideana(x, medias)
distancias = zeros(1,length(medias));
for i = 1:length(medias)
    % Se almacenan la distancia
    % de la media i al vector desonocido
    % x
    try
        distancias(i) = norm(medias{i}(1:3) - x(1:3));
    catch e
        distancias(i) = norm(medias(i,:) - x);
    end
end

[~ , numClase] = min(distancias);
end