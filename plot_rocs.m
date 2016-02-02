%Load Random Forest Results
r = h5read('randomforest_results_wg.h5', '/roc_vals');
semilogx(r(1,:), r(2,:), '-s');
ylabel('TP Rate')
xlabel('Avg # Falses per Scan')
grid on
legend('Object Classifier')
%Load Ilastik Results