clc
clear all
close all
load('solar_data.mat')
ir_filter
lamda=(280:4000)';
IR_filter=interp1(IR_filter_raw(:,1),IR_filter_raw(:,2),lamda);
% solar_data(doy,hour,wavelength,1)
% tip (1=diff_horiz,2=direct_horiz,3=aci)
par_start_ind=400-280+1;
par_end_ind=700-280+1;
direct_solar=zeros(365,24);
direct_solar_IR_filter=zeros(365,24);
PAR=zeros(365,24);
PAR_IR_filter=zeros(365,24);
for doy=1:365
    for hour=1:24
        direct_solar_lamda=solar_data(:,1,doy,hour);
        filtered_direct_solar_lamda=IR_filter.*direct_solar_lamda;
        direct_par_lamda=solar_data(:,3,doy,hour);
        filtered_direct_par_lamda=direct_par_lamda.*IR_filter;

        
        direct_solar(doy,hour)=trapz(lamda,direct_solar_lamda);
        direct_solar_IR_filter(doy,hour)=trapz(lamda,filtered_direct_solar_lamda);
        PAR(doy,hour)=trapz(lamda(par_start_ind:par_end_ind),direct_par_lamda(par_start_ind:par_end_ind));
        PAR_IR_filter(doy,hour)=trapz(lamda(par_start_ind:par_end_ind),filtered_direct_par_lamda(par_start_ind:par_end_ind));

    end
end

% Light Calculation Starts

solar_collector_area = 100;
greenhouse_area = 100; % from top view in m^2
hour_light = 20; %20h / 24h lighting will be used  https://doi.org/10.1626/JCS.58.689
number_of_shelves = 7;
desired_PAR_per_shelf = 120;
total_PAR_required = desired_PAR_per_shelf * number_of_shelves * greenhouse_area;
ita_cd = 0.5; 
PAR_from_cd = PAR * ita_cd * solar_collector_area;
PAR_from_cd_IR_filter = PAR_IR_filter * ita_cd * solar_collector_area;

LED_compansate = total_PAR_required - PAR_from_cd; % find the amount to be compansated by LEDs
LED_compansate(LED_compansate<0)=0; % can't compansate negatives, so make them zero
LED_compansate(:,hour_light+1:end)=0; %close the lights after 20h
LED_compansate_IR_filter = total_PAR_required - PAR_from_cd_IR_filter;
LED_compansate_IR_filter(LED_compansate_IR_filter<0)=0;  % can't compansate negatives, so make them zero
LED_compansate_IR_filter(:,hour_light+1:end)=0;  %close the lights after 20h
% Light Calculation Ends

% Heat Load Calculations Starts
ita_cd_thermal = 0.7; % i think it should be larger than ita_cd as absorption in fiber contributes to heating
Q_solar = direct_solar * ita_cd_thermal * solar_collector_area; %in Watt
Q_solar_IR_filter = direct_solar_IR_filter * ita_cd_thermal * solar_collector_area; %in Watt

coeff = 3.3; % https://www.assets.signify.com/is/content/Signify/Assets/philips-lighting/global/20211217-production-module.pdf
Q_led = LED_compansate / coeff; %in Watt
Q_led_IR_filter = LED_compansate_IR_filter / coeff; %in Watt

Q_total_load = Q_solar + Q_led; %in Watt
Q_total_load_IR_filter = Q_solar_IR_filter + Q_led_IR_filter; %in Watt
% Heat Load Calculations Ends


% figure
% contourf(direct_solar)
% cb1 = colorbar;
% hAx=gca;
% hAx.XColor = [0 0 0];
% hAx.YColor = [0 0 0];
% hAx.LineWidth = 1.5;
% axis square
% hLg.EdgeColor = [0 0 0];
% xlabel('Hour, h [h]')
% ylh=ylabel('Day of the year');
% ylh.VerticalAlignment	= 'bottom'; %if it is not alligned well, try 'top' and 'bottom' too
% set(gca,'FontSize',13)
% figure
% contourf(direct_solar_IR_filter)
% cb2 = colorbar;
% figure
% contourf(PAR)
% cb3 = colorbar;
% figure
% contourf(PAR_IR_filter)
% cb4 = colorbar;