%% Initialization 
clear all; close all; clc 
 T = readtable("movimento_alto_e_basso.txt"); % input IMU data
% T = readtable("dataLog00169.TXT"); % input IMU data
%% Input parameters
accel_fs = 10; % lpf accelerometer [Hz]
gyro_fs = 15; % lpf gyroscope [Hz]
clr=[0.3 0.3 0.3]; % color of non-filtered data
%% Parameters processing
% IMU data sorting
accel_raw = T{:,{'aX','aY','aZ'}}; % [mg]
gyro_raw = T{:,{'gX','gY','gZ'}}; % [dps]
% IMU data conversion
accel_raw = accel_raw/1000*9.81; % [m/s^2]
t = (T.micros - T.micros(1))*(1e-6); % time [s]
% IMU auxiliary variables
fs=round(1/t(2)); % sampling frequency [Hz]
% IMU data filtering
[b_accel,a_accel] = butter(9,accel_fs/(fs)); % design order 9 Butterworth filter accelerometer
[b_gyro,a_gyro] = butter(9,gyro_fs/(fs)); % design order 9 Butterworth filter accelerometer
%accel_offset = mean(accel_raw(1:750,:)); % [m/s^2]
%gyro_offset = mean(gyro_raw(1:750,:)); % [deg/s]

accel_offset=[-9.2113,-2.9665,25.0151];
accel_scale=[0.0010,0.0010,0.0010];

x_calibrated = (accel_raw(:,1) - accel_offset(1)) * accel_scale(1);
y_calibrated = (accel_raw(:,2) - accel_offset(2)) * accel_scale(2);
z_calibrated = (accel_raw(:,3) - accel_offset(3)) * accel_scale(3);

accel_calibrated = [x_calibrated,y_calibrated,z_calibrated];
accel_f = filtfilt(b_accel,a_accel,accel_calibrated);
gyro_f = filtfilt(b_gyro,a_gyro,gyro_raw);



%accel_offset = [-0.39, -0.28, -9.81+9.88];
%gyro_offset = [0.1178   -0.0785    0.1692];
% IMU data correction
%accel = accel_f - accel_offset; % [m/s^2]
%gyro = gyro_f - gyro_offset; % [deg/s]
gyro = gyro_f*pi/180; % [rad/s]

accel = accel_f';
gyro = gyro';
%% Data Integration
% Acceleration Integration
n = length(t);
accel_tot = zeros(3,n);
vel_earth = zeros(3,n); % velocity initial condition (body axes)
quat = ones(4,n); % Quaternion [q0,q1,q2,q3]
quat(:,1) = [1; 0; 0; 0]; % initial condition 
% quat(:,1) = [0.707; 0; 0.707; 0]; % initial condition 
eul = zeros(3,n); % Euler Angles initial condition [Yaw (psi) - Pitch (theta) - Roll (phi)]
% eul(2,1) = pi/2;
pos = zeros(3,n); % position initial condition
for k=1:(n-1)
    A = -0.5*[     0      gyro(1,k)  gyro(2,k) gyro(3,k);
             -gyro(1,k)      0     -gyro(3,k) gyro(2,k);
             -gyro(2,k)  gyro(3,k)     0     -gyro(1,k);
             -gyro(3,k) -gyro(2,k)  gyro(1,k)    0     ];
    quat(:,k+1) = quat(:,k)+A*quat(:,k)*(t(k+1)-t(k)); % quaternion
    norm_quat = sqrt(sum(quat(:,k+1).^2, 1));
    quat(:,k+1) = quat(:,k+1)./norm_quat;
    eul(3,k+1) = atan2(2*(quat(3,k+1)*quat(4,k+1)+quat(1,k+1)*quat(2,k+1)),(quat(1,k+1)^2-quat(2,k+1)^2-quat(3,k+1)^2+quat(4,k+1)^2)); % roll (phi)
    eul(2,k+1) = atan2(-2*(quat(2,k+1)*quat(4,k+1)-quat(1,k+1)*quat(3,k+1)),sin(eul(3,k+1))*2*(quat(3,k+1)*quat(4,k+1)+quat(1,k+1)*quat(2,k+1))+cos(eul(3,k+1))*(quat(1,k+1)^2-quat(2,k+1)^2-quat(3,k+1)^2+quat(4,k+1)^2)); % pitch (theta) 
    eul(1,k+1) = atan2(-cos(eul(3,k+1))*2*(quat(2,k+1)*quat(3,k+1)+quat(1,k+1)*quat(4,k+1))+sin(eul(3,k+1))*2*(quat(2,k+1)*quat(4,k+1)+quat(1,k+1)*quat(3,k+1)),cos(eul(3,k+1))*(quat(1,k+1)^2-quat(2,k+1)^2+quat(3,k+1)^2-quat(4,k+1)^2)-sin(eul(3,k+1))*(2*(quat(3,k+1)*quat(4,k+1)-quat(1,k+1)*quat(2,k+1)))); % yaw (psi)
    L = [cos(eul(2,k+1))*cos(eul(1,k+1)), -cos(eul(3,k+1))*sin(eul(1,k+1))+sin(eul(3,k+1))*sin(eul(2,k+1))*cos(eul(1,k+1)), sin(eul(3,k+1))*sin(eul(1,k+1))+cos(eul(3,k+1))*sin(eul(2,k+1))*cos(eul(1,k+1));
         cos(eul(2,k+1))*sin(eul(1,k+1)), cos(eul(3,k+1))*cos(eul(1,k+1))+sin(eul(3,k+1))*sin(eul(2,k+1))*sin(eul(1,k+1)), -sin(eul(3,k+1))*cos(eul(1,k+1))+cos(eul(3,k+1))*sin(eul(2,k+1))*sin(eul(1,k+1));
         -sin(eul(2,k+1)), sin(eul(3,k+1))*cos(eul(2,k+1)), cos(eul(3,k+1))*cos(eul(2,k+1))];
    accel_earth(:,k) = L*accel(:,k); % acceleration in NED;
    accel_tot(1,k) = accel_earth(1,k);
    accel_tot(2,k) = accel_earth(2,k);
    accel_tot(3,k) = accel_earth(3,k)-9.81;
    vel_earth(:,k+1) = vel_earth(:,k)+accel_tot(:,k)*(t(k+1)-t(k));
end

% [b_vel, a_vel] = butter(1,accel_fs/(fs*10),'high');
% vel_earth = filtfilt(b_vel,a_vel,vel_earth');
% vel_earth = vel_earth';

for k=1:n-1
    pos(:,k+1) = pos(:,k)+vel_earth(:,k)*(t(k+1)-t(k));
end

% [b_pos, a_pos] = butter(1,accel_fs/(fs*50),'high');
% pos = filtfilt(b_pos,a_pos,pos');
% pos = pos';

%% Figures
% ACCELERATIONS (BODY AXES)
figure(1)
hold on
plot(t,accel_f(:,1),'r','LineWidth',2)
plot(t,accel_raw(:,1),'.-','MarkerSize',1,'Color',clr)
plot(t,accel(1,:),'r--','LineWidth',2)
xlabel('t [s]')
ylabel('a_x [m/s^2]')
xlim([t(1),t(end)])
legend('filtered','raw','filtered and corrected with offset')
%
figure(2)
hold on
plot(t,accel_f(:,2),'g','LineWidth',2)
plot(t,accel_raw(:,2),'.-','MarkerSize',1,'Color',clr)
plot(t,accel(2,:),'g--','LineWidth',2)
xlabel('t [s]')
ylabel('a_y [m/s^2]')
xlim([t(1),t(end)])
legend('filtered','raw')
%
figure(3)
hold on
plot(t,accel_f(:,3),'b','LineWidth',2)
plot(t,accel_raw(:,3),'.-','MarkerSize',1,'Color',clr)
plot(t,accel(3,:),'b--','LineWidth',2)
xlabel('t [s]')
ylabel('a_z [m/s^2]')
xlim([t(1),t(end)])
legend('filtered','raw','filtered and corrected with offset')
% ANGULAR RATES (BODY AXES)
figure(5)
hold on
plot(t,gyro_f(:,1),'r','LineWidth',3)
plot(t,gyro_raw(:,1),'.-','MarkerSize',1,'Color',clr)
xlabel('t [s]')
ylabel('\omega_x [deg/s]')
%xlim([t0 tf])
xlim([t(1),t(end)])
legend('filtered','raw')
%
figure(6)
hold on
plot(t,gyro_f(:,2),'g','LineWidth',2)
plot(t,gyro_raw(:,2),'.-','MarkerSize',1,'Color',[0.7 0.7 0.7])
xlabel('t [s]')
ylabel('\omega_y [deg/s]')
%xlim([t0 tf])
xlim([t(1),t(end)])
legend('filtered','raw')
%
figure(7)
hold on
plot(t,gyro_f(:,3),'b','LineWidth',2)
plot(t,gyro_raw(:,3),'.-','MarkerSize',1,'Color',clr)
xlabel('t [s]')
ylabel('\omega_z [deg/s]')
%xlim([t0 tf])
xlim([t(1),t(end)])
legend('filtered','raw')

%
figure()
hold on
plot(t',vel_earth(1,:),'b','linewidth',2);
plot(t',vel_earth(2,:),'g','linewidth',2);
plot(t',vel_earth(3,:),'r','linewidth',2);
title('Velocity')
legend('Vx','Vy','Vz');
grid on

figure()
hold on
plot(t',pos(1,:),'b','linewidth',2);
plot(t',pos(2,:),'g','linewidth',2);
%plot(t',pos(3,:),'r','linewidth',2);
xlabel('t [s]')
ylabel('position [m]')
title('Position')
legend('x','y','z');
grid on

figure()
plot(t',pos(3,:),'r','linewidth',2);
title('Altitude vs time')
xlabel('t [s]');
ylabel('z [m]');
yline(0);

figure()
plot3(pos(1,:),pos(2,:),pos(3,:),'m','linewidth',2);
hold on
plot3(pos(1,1),pos(2,1),pos(3,1),'xb','linewidth',2);
plot3(pos(1,end),pos(2,end),pos(3,end),'or','linewidth',2);
title('Trajectory');
xlabel('x [m]')
ylabel('y [m]')
zlabel('z [m]')
grid on
axis equal

figure()
hold on
plot(t',eul(1,:)*180/pi,'b','linewidth',2);
plot(t',eul(2,:)*180/pi,'g','linewidth',2);
plot(t',eul(3,:)*180/pi,'r','linewidth',2);
title('Euler Angles (Attitude)')
xlabel('t [s]')
ylabel('angle [°]')
legend('\psi','\theta','\phi');
grid on
