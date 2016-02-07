%Load Random Forest Results
figure;
[tp, fp] = get_interpolationpoints('predictionsd1.h5', 5);
semilogx(fp, tp, '-.s');
hold on

[tp, fp] = get_interpolationpoints('predictionsd2.h5', 5);
semilogx(fp, tp, '-.s');

[tp, fp] = get_interpolationpoints('predictionsd3.h5', 5);
semilogx(fp, tp, '-.s');

[tp, fp] = get_interpolationpoints('predictionsd4.h5', 5);
semilogx(fp, tp, '-.s');

[tp, fp] = get_interpolationpoints('predictionsd5.h5', 5);
semilogx(fp, tp, '-.s');

[tp, fp] = get_interpolationpoints('predictions.h5', 5);
semilogx(fp, tp, '-.s');

ylabel('Dogru Tesbit Orani')
xlabel('Tarama Basina Ortalama Yanlis Tesbit')
grid on
xlim([0 10])
ylim([0 1])
legend('Deney 1', 'Deney 2', 'Deney 3' , 'Deney 4', 'Deney 5', 'Tum Oznitelikler')


%Load Ilastik Results
figure;
sa = [1/8 0.135; 1/4 0.150; 1/2 0.193; 1 0.23; 2 0.246; 4 0.261; 8 0.261]';
semilogx(sa(1,:), sa(2,:), '-s');
hold on
sb = [1/8 0.111; 1/4 0.150; 1/2 0.188; 1 0.266; 2 0.377; 4 0.454; 8 0.488]';
semilogx(sb(1,:), sb(2,:), '-s');
sc = [1/8 0.043; 1/4 0.058; 1/2 0.140; 1 0.232; 2 0.333; 4 0.454; 8 0.517]';
semilogx(sc(1,:), sc(2,:), '-s');
sd = [1/8 0.068; 1/4 0.126; 1/2 0.208; 1 0.285; 2 0.357; 4 0.464; 8 0.546]';
semilogx(sd(1,:), sd(2,:), '-s');
se = [1/8 0.450; 1/4 0.488; 1/2 0.570; 1 0.638; 2 0.712; 4 0.768; 8 0.797]';
semilogx(se(1,:), se(2,:), '-s');
sf = [1/8 0.034; 1/4 0.067; 1/2 0.127; 1 0.208; 2 0.276; 4 0.392; 8 0.512]';
semilogx(sf(1,:), sf(2,:), '-s');


[tp, fp] = get_interpolationpoints('predictions.h5', 5);
semilogx(fp, tp, '-.s');

xlim([0 10])
ylim([0 1])
ylabel('Dogru Tesbit Orani')
xlabel('Tarama Basina Ortalama Yanlis Tesbit')
grid on
legend('Sistem A', 'Sistem B', 'Sistem C', 'Sistem D', 'Sistem E', 'Sistem F', 'Onerilen Sistemimiz');