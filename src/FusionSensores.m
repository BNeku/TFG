
%% Fusi�n de sensores 
clear all; close all;
% Recuperar los datos del Sensor
load AccOrienMagn

% Fusi�n Aceler�metro-Magnet�metro
viewer1 = fusiondemo.OrientationViewer;

[Ma,Na] = size(aceleracion); [Mm,Nm] = size(magnetico); 
MinMaMn = min(Ma,Mm);

AceleracionXYZ = aceleracion(1:MinMaMn,:);
MagneticoXYZ   = magnetico(1:MinMaMn,:);

qe = ecompass(AceleracionXYZ, MagneticoXYZ); 
title('Aceler�metro-Magnet�metro')
for ii=1:size(AceleracionXYZ,1)
  viewer1(qe(ii));
  pause(0.01);
end

% Fusi�n Aceler�metro-Gir�scopo
viewer2 = fusiondemo.OrientationViewer;
[Ma,Na] = size(aceleracion); [Mo,No] = size(orientacion); 
MinMaMo = min(Ma,Mo);

AceleracionXYZ = aceleracion(1:MinMaMo,:);
OrientacionXYZ = orientacion(1:MinMaMo,:);

Fs = 200;
ifilt = imufilter('SampleRate', Fs);
title('Aceler�metro-Gir�scopo')
for ii=1:size(AceleracionXYZ,1)
  qimu = ifilt(AceleracionXYZ(ii,:), OrientacionXYZ(ii,:));
  viewer2(qimu);
  pause(0.01);
end

MinTodos = min(MinMaMn, MinMaMo);
AceleracionXYZ = aceleracion(1:MinTodos,:);
OrientacionXYZ = orientacion(1:MinTodos,:);
MagneticoXYZ   = magnetico(1:MinTodos,:);

% Fusi�n Aceler�metro-Gir�scopo-Magent�metro
viewer3 = fusiondemo.OrientationViewer;
ifilt = ahrsfilter('SampleRate', Fs);
title('Aceler�metro-Gir�scopo-Magent�metro')
for ii=1:size(AceleracionXYZ,1)
  qahrs = ifilt(AceleracionXYZ(ii,:), OrientacionXYZ(ii,:), MagneticoXYZ(ii,:));
  viewer3(qahrs);
  pause(0.01);
end
