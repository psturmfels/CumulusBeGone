NUM_BINS = 50;
K = 100;
NUM_TRAINDATA = 400;
NUM_TREES = 500;
%Get data and labels for decision tree classifier
[X, Labels] = meanColorHist(NUM_BINS, K, NUM_TRAINDATA);
B = TreeBagger(NUM_TREES, X, Labels, 'OOBPrediction', 'On');

figure;
oobErrorBaggedEnsemble = oobError(B);
plot(oobErrorBaggedEnsemble)
xlabel 'Number of grown trees';
ylabel 'Out-of-bag classification error';

save 'DecisionTreeClassifier'  B;