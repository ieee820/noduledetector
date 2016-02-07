%% This file calculates the froc exactly anode09 describes

r = h5read('predictions.h5', '/p_vals')';
B = sortrows(r,1);
B = flipud(B);
%take only 2k, has all the nodules, no worry about that
B = B(1:2000, :);

tholds = linspace(max(B(:, 1)), 0.45, 100);

rates = zeros(1, length(tholds));
falses = zeros(1, length(tholds));
totalnodules = length(find(B(:,2)==1));
for i=1:length(tholds)
    truepositive = 0;
    falsepositive = 0;
    negative = 0;
    detections = B(:, 1)>tholds(i);
    labels = double(B(:, 2));
    
    for j = 1: length(detections)
        d = detections(j);
        l = labels(j);
        if d==1 && l==1
            truepositive = truepositive + 1;
        elseif d==1 && l==0
            falsepositive = falsepositive + 1;
        elseif d==0 && l==1
            negative = negative + 1;
        end
    end
    rates(1, i) = truepositive ./ totalnodules;
    falses(1, i) = falsepositive ./ 5; % 5 for test count
end

concat = [rates ;falses]';
%Get lowest falses
B = sortrows(concat,-2);
[~,I]=unique(B(:,2),'first');
maximals = B(I,:);

%With highes rate
[~,I]=unique(maximals(:,1),'first');
resulting = maximals(I, :);

%Interpolate points which are missing
falses = [1/8 1/4 1/2 1 2 4 8];
trues = interp1(resulting(:,2), resulting(:,1), falses);


%Draw Others
figure;
sa = [1/8 0.135; 1/4 0.150; 1/2 0.193; 1 0.23; 2 0.246; 4 0.261; 8 0.261]';
semilogx(sa(1,:), sa(2,:), '-s');
hold on;
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

%Draw ours
semilogx(falses, trues, '-.s');

grid on;
xlim([0 10])
ylim([0 1])
ylabel('Dogru Tesbit Orani')
xlabel('Tarama Basina Yanlis Tesbit')
grid on
legend('Sistem A', 'Sistem B', 'Sistem C', 'Sistem D', 'Sistem E', 'Sistem F', 'Onerilen Sistemimiz');