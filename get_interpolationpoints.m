function [tp, fp] = get_interpolationpoints(h5filee, totaltest)
r = h5read(h5filee, '/p_vals')';
B = sortrows(r,1);
B = flipud(B);
%take only 2k, has all the nodules, no worry about that
By = B;
B = B(1:2000, :);

tholds = linspace(max(B(:, 1)), 0.2, 100);

rates = zeros(1, length(tholds));
falses = zeros(1, length(tholds));
totalnodules = length(find(By(:,2)==1));
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
    falses(1, i) = falsepositive ./ totaltest; % 5 for test count
end

concat = [rates ;falses]';
%Get lowest falses
B = sortrows(concat,-2);
[~,I]=unique(B(:,2),'last');
maximals = B(I,:);

%With highes rate
[~,I]=unique(maximals(:,1),'first');
resulting = maximals(I, :);

%Interpolate points which are missing
fp = [1/8 1/4 1/2 1 2 4 8];
tp = interp1(resulting(:,2), resulting(:,1), fp);

end

