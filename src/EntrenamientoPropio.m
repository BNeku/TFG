clear all

%% Previamente se carga el nombre del fichero, por ejemplo Sentada.mat
load Sentada

% Cargar XTrain e YTrain desde HumanActivityTrain 
load HumanActivityTrain

%Tras la carga, aparece la Variable Acceleration en el espacio de trabajo

% Cálculo del número de datos en aceleración
NumDatos = size(Acceleration,1);

% Se eliminan, por ejemplo los 100 primeros y los 100 últimos. Se pueden
% eliminar más si se quieren. Esto es para eliminar datos falsos, ya que
% desde que se inicia el sensor hasta que se empieza la actividad estos
% datos no sirven y lo mismo ocurre al final, cuando se acaba hasta que se
% apaga el sensor.

Nexluir = 100; %Datos a excluiir
X(:,1) = Acceleration.X(Nexluir+1:NumDatos-Nexluir);
X(:,2) = Acceleration.Y(Nexluir+1:NumDatos-Nexluir);
X(:,3) = Acceleration.Z(Nexluir+1:NumDatos-Nexluir);

% transponemos X para cambiar filas por columnas, de forma que ahora 
% cada columna de X es un dato de aceleración.
X=X';

NuevoTrainSentada{1,1}=X;

%% Ahora hay que hacer algo parecido para YTrain, creando lo que se llama categorical "array"
DatosY = size(X,2);
for i=1:DatosY
    Y{i} = 'Sitting';
end

% Transformación a un categorical array
Ynew = categorical(Y);

%% PARTE a ejecutar
PARTE = 1;

if PARTE == 1
  %% PARTE I (Exluyente con la PARTE II y III)
  % Los datos captados se añaden a XTrain creando la celda 7
  XTrain{7,1}=X;

  % Como YTrain tenía 6 celdas ahora estos datos los añadimos a YTrain
  YTrain{7,1}=Ynew;
elseif PARTE == 2
  %% PARTE II (Excluyente con la PARTE I y III)
  % Añadir datos a una estructura existente sin crear nuevos datos.
  % Ejemplo para añadirla en la celda 3. En el ejemplo procedente de 
  % la celda 3 con 56416 datos a los que se añaden los 428 de Acceleration,
  % resultando un total de 56844

  %Calculamos el número de datos de la celda
  datos_celda = size(XTrain{3,1}(1,:),2);

  % Cálculo del número de datos en aceleración
  NumDatos = size(Acceleration,1);

  % Con esta operación se añaden los 428 datos al final de la celda 3 
  XTrain{3,1}(:,datos_celda+1:datos_celda+NumDatos) = X;
  YTrain{3,1}(:,datos_celda+1:datos_celda+NumDatos) = Ynew;

else
  %% PARTE III (Excluyente con la PARTE I y II)
  % Se borran los datos de XTrain e YTrain
  clear XTrain YTrain
  XTrain{1,1}=X;
  YTrain{1,1}=Ynew;

end
  
  %% En cualquier caso se guradan los datos tanto de la parte I como de la Parte II
save ActividadesNuestras XTrain YTrain