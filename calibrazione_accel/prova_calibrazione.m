close all; clear all;
x_data = readtable('D:\Desktop\RocketLab2023\RocketnRoll_MATLAB_2023\RealTerm\captures\calibr_x.txt');
y_data = readtable('D:\Desktop\RocketLab2023\RocketnRoll_MATLAB_2023\RealTerm\captures\calibr_y.txt');
z_data = readtable('D:\Desktop\RocketLab2023\RocketnRoll_MATLAB_2023\RealTerm\captures\calibr_z.txt');

ax = x_data{:,{'aX','aY','aZ'}}; % [mg]
ay = y_data{:,{'aX','aY','aZ'}}; % [mg]
az = z_data{:,{'aX','aY','aZ'}}; % [mg]

nx = length(ax)
ny = length(ay)
nz = length(az)

%visto che sono scemo le catture di x sono prima tutte negative e poi tutte
%positive
for x=1:nx 
    %stampa l'ultimo elemento negativo
    if ax(x,1) < 0
        ax(x,:)
        treshold_x = x
    end
end

for y=1:ny 
    %stampa l'ultimo elemento positivo
    if ay(y,2) > 0
        ay(y,:)
        treshold_y = y
    end
end

for z=1:nz 
    %stampa l'ultimo elemento positivo
    if az(z,3) > 0
        az(z,:)
        treshold_z = z
    end
end

%visto che sono scemo le catture di x sono prima tutte negative e poi tutte
%positiva
x_1g = mean(ax(treshold_x:nx,1))
x_n1g = mean(ax(1:treshold_x,1));
%
y_1g = mean(ay(1:treshold_y,2));
y_n1g = mean(ay(treshold_y:ny,2));
z_1g = mean(az(1:treshold_z,3));
z_n1g = mean(az(treshold_z:nz,3));

% Calcola i fattori di scala per ciascun asse
x_scale = 2 / (x_1g - x_n1g);
y_scale = 2 / (y_1g - y_n1g);
z_scale = 2 / (z_1g - z_n1g);

% Calcola gli offset per ciascun asse
x_offset = (x_1g + x_n1g) / 2;
y_offset = (y_1g + y_n1g) / 2;
z_offset = (z_1g + z_n1g) / 2;

% Calibra i valori grezzi dell'accelerometro
%in un caso reale al posto di ax,ay,az bisogna mettere i dati catturati
%realmente

x_calibrated = (ax - x_offset) * x_scale;
y_calibrated = (ay - y_offset) * y_scale;
z_calibrated = (az - z_offset) * z_scale;