function [hist_x] = calculate_histmag(mag_x, angle_x, th)
hist_x = zeros(1, 9);
for i = 1 : size(mag_x, 1) * size(mag_x, 2),
    if mag_x(i)>th
        alpha = angle_x(i);
        if alpha>10 && alpha<=30
            hist_x(1)=hist_x(1)+ mag_x(i)*(30-alpha)/20;
            hist_x(2)=hist_x(2)+ mag_x(i)*(alpha-10)/20;
        elseif alpha>30 && alpha<=50
            hist_x(2)=hist_x(2)+ mag_x(i)*(50-alpha)/20;
            hist_x(3)=hist_x(3)+ mag_x(i)*(alpha-30)/20;
        elseif alpha>50 && alpha<=70
            hist_x(3)=hist_x(3)+ mag_x(i)*(70-alpha)/20;
            hist_x(4)=hist_x(4)+ mag_x(i)*(alpha-50)/20;
        elseif alpha>70 && alpha<=90
            hist_x(4)=hist_x(4)+ mag_x(i)*(90-alpha)/20;
            hist_x(5)=hist_x(5)+ mag_x(i)*(alpha-70)/20;
        elseif alpha>90 && alpha<=110
            hist_x(5)=hist_x(5)+ mag_x(i)*(110-alpha)/20;
            hist_x(6)=hist_x(6)+ mag_x(i)*(alpha-90)/20;
        elseif alpha>110 && alpha<=130
            hist_x(6)=hist_x(6)+ mag_x(i)*(130-alpha)/20;
            hist_x(7)=hist_x(7)+ mag_x(i)*(alpha-110)/20;
        elseif alpha>130 && alpha<=150
            hist_x(7)=hist_x(7)+ mag_x(i)*(150-alpha)/20;
            hist_x(8)=hist_x(8)+ mag_x(i)*(alpha-130)/20;
        elseif alpha>150 && alpha<=170
            hist_x(8)=hist_x(8)+ mag_x(i)*(170-alpha)/20;
            hist_x(9)=hist_x(9)+ mag_x(i)*(alpha-150)/20;
        elseif alpha>=0 && alpha<=10
            hist_x(1)=hist_x(1)+ mag_x(i)*(alpha+10)/20;
            hist_x(9)=hist_x(9)+ mag_x(i)*(10-alpha)/20;
        elseif alpha>170 && alpha<=180
            hist_x(9)=hist_x(9)+ mag_x(i)*(190-alpha)/20;
            hist_x(1)=hist_x(1)+ mag_x(i)*(alpha-170)/20;
        end
    end
end
hist_x=hist_x/sqrt(norm(hist_x)^2+.01);
end

