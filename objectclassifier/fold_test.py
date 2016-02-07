import h5py
from accurancyTools import *
from sklearn import ensemble
from datasets import *

trainingDataSetNames = ['Volume', 'PseudoRadius', 'Complexity',
    'BoundingBox2Volume', 'BoundingBoxAspectRatio', 'IntensityMax',
    'IntensityMin', 'CloseMassRatio', 'IntensityHist',
    'Gradient', 'GradientOfMag']

senaryo = get_sets(trainingDataSetNames)

alphaStep = 20
alphaStart = 0.2
alphaStop = 0.9
alphaRange = numpy.linspace(alphaStart, alphaStop, alphaStep)
treeCount = 80
roc_iterator = 0
random_seed = 1
numpy.random.seed(random_seed)
totalpositives = 0


testcount = 100
TPMAT = numpy.zeros((testcount, alphaStep))
FPMAT = numpy.zeros((testcount, alphaStep))
a = 0
s_ite = 0

foldtestfiles = senaryo['train_set']
for i in range(testcount):
    [train, test] = foldtestfiles.divideSetRandom(0.75, 0.25, i)
    totalpositives += sum(test.labels == 1)
    rf = ensemble.RandomForestClassifier(n_estimators=treeCount, random_state=10)
    rf.fit(train.data, numpy.ravel(train.labels))
    p = rf.predict_proba(test.data)
    for alpha in alphaRange:
        pred_bias = numpy.array([1-alpha, alpha])
        results = calculate_accuracy(1, p, test.labels, bias=pred_bias)
        TPMAT[s_ite, a] = results['tpnumber']
        FPMAT[s_ite, a] = results['fpnumber']
        a += 1
    s_ite += 1
    a = 0


avg_tp_rate = numpy.sum(TPMAT, axis=0)
avg_tp_rate /= totalpositives
avg_fp_number = numpy.sum(FPMAT, axis=0)
avg_fp_number /= testcount

#print 'Mult. : ', mult
print 'TreeCount :', treeCount
for x in range(0, alphaStep-1):
        print 'Alpha : ', format(alphaRange[x], '.3f'), '& TP : ', format(avg_tp_rate[x], '.3f'), \
              '& FP : &', format(avg_fp_number[x], '.3f')


