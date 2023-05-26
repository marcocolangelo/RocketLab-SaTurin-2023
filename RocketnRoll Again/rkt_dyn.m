function dX=rkt_dyn(t,X)   %rocket dynamic = dinamica del razzo
global g A cD Ap Isp th cDp rho tb td tT

%A % rocket cross section [m^2]
cD % drag coefficient [#]
Ap % parachute area [m^2]
cDp% drag coefficient [#]
g % acceleration of gravity [m/s^2]
%th_deg % heading angle (angolo iniziale con cui posiziono il razzo) [deg]
%rho % air density [kg/m^3]
% tT=[0 0; 0.1 9.2;0.2 25;0.3 15;0.4 10; ...]; SPINTA ad un DATO SECONDO per lo specifico modello di motore ex. a 0.1 secondi la SPINTA è 9.2 % D9-3
%td=3; delay tra spegnimento del motore ed esplosione carica per far fuoriscire paracadute
Isp % specific impulse [s] -> caratteristica fisica del propollente e ne indica l'efficienza a parità di spinta
%tb=tT(end,1); -> time burn, ovvero il tempo dell'ultimo valore diverso da 0 della spinta
%th conversione in radianti di th_deg


x=X(1);
y=X(2);
vx=X(3);
vy=X(4);
m=X(5);

gamma=atan2(vy,vx);

%velocità assoluta
v=sqrt(vx^2+vy^2);

if t<=tb+td
    D=0.5*rho*v^2*A*cD;
else
    D=0.5*rho*v^2*Ap*cDp; % exp opening
end

if t<=tb
    Ta=interp1(tT(:,1),tT(:,2),t);
    dm=-Ta/g/Isp;
else
    Ta=0;
    dm=0;
end

ax=Ta*cos(th)/m-D/m*cos(gamma);
ay=Ta*sin(th)/m-D/m*sin(gamma)-g;

dX(1,1)=vx;
dX(2,1)=vy;
dX(3,1)=ax;
dX(4,1)=ay;
dX(5,1)=dm;
