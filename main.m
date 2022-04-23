clc
clear all
%solar_data(hour,wavelength,type(1=diff_horiz,2=direct_horiz,3=aci))
solar_data=single(zeros(3721,3,365,24));
latitude=40;
for doy=1:365
    for hour=1:24
        delete smarts295.out.txt
        delete smarts295.ext.txt
        [yy,mm,dd,HH,MM] = datevec(datenum(2022,1,doy));
        fid = fopen('smarts295.inp.txt', 'w');
        fprintf(fid,'''Example''  !Card 1 Comment\r\n');
        fprintf(fid,'1  !Card 2 ISPR\r\n');
        fprintf(fid,'1013.25 0. 0. !Card 2a Pressure & altitude\r\n');
        fprintf(fid,'1 !Card 3 IATMOS\r\n');
        fprintf(fid,'''USSA'' !Card 3a Atmosphere\r\n');
        fprintf(fid,'1 !Card 4 IH2O\r\n');
        fprintf(fid,'1 !Card 5 IO3, AbO3\r\n');
        fprintf(fid,'1 !Card 6 IGAS\r\n');
        fprintf(fid,'370 !Card 7 qCO2\r\n');
        fprintf(fid,'1 !Card 7a qCO2\r\n');
        fprintf(fid,'''S&F_RURAL'' !Card 8 Aeros\r\n');
        fprintf(fid,'0 !Card 9\r\n');
        fprintf(fid,'0.085 !Card 9a qCO2\r\n');
        fprintf(fid,'26 !Card 10 IALBDX\r\n');
        fprintf(fid,'0 !Card 10b ITILT\r\n');
        fprintf(fid,'280 4000 1.0 1367.0 !Card 11 Input wavelengths; solar constant modifier; solar constant\r\n');
        fprintf(fid,'2 !Card 12 IPRT\r\n');
        fprintf(fid,'280 4000 1.0 !Card 12a Instrument characteristics\r\n');
        fprintf(fid,'3\r\n');
        fprintf(fid,'2 3 36\r\n');
        fprintf(fid,'0 !Card 13 ICIRC\r\n');
        fprintf(fid,'0 !Card 14 ISCAN\r\n');
        fprintf(fid,'0 !Card 15 ILLUM\r\n');
        fprintf(fid,'1 !Card 16 IUV\r\n');
        fprintf(fid,'3 !Card 17 IMASS\r\n');
        fprintf(fid,'%d %d %d %d %d 0.0 0\r\n',yy,mm,dd,hour,latitude);
        fclose(fid);
        [x, y] = system('smarts295bat.exe');

        C = readmatrix('smarts295.ext.txt');

        if isempty(C)
            solar_data(:,1,doy,hour)=single(zeros(1,3721));
            solar_data(:,2,doy,hour)=single(zeros(1,3721));
            solar_data(:,3,doy,hour)=single(zeros(1,3721));
        else
            solar_data(:,1,doy,hour)=single(interp1(C(:,1),C(:,2),280:4000,'linear','extrap'));
            solar_data(:,2,doy,hour)=single(interp1(C(:,1),C(:,3),280:4000,'linear','extrap'));
            solar_data(:,3,doy,hour)=single(interp1(C(:,1),C(:,4),280:4000,'linear','extrap'));
        end
    end
end
save('solar_data.mat','solar_data')
