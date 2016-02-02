import h5py
from accurancyTools import *
from sklearn import ensemble
from datasets import *

trainingDataSetNames = ['Volume', 'PseudoRadius', 'Complexity',
    'BoundingBox2Volume', 'BoundingBoxAspectRatio', 'IntensityMax',
    'IntensityMin', 'CloseMassRatio', 'IntensityHist',
    'gaussianCoeffsz', 'Gradient', 'GradientOfMag', 'ssimz']

senaryo = get_sets(trainingDataSetNames)

alphaStep = 20
alphaStart = 0.1
alphaStop = 0.6
alphaRange = numpy.linspace(alphaStart, alphaStop, alphaStep)
treeCount = 80
roc_iterator = 0
random_seed = 1
numpy.random.seed(random_seed)

analysefalseatalpha = 0.5
analyseatset = 1

totalpositives = 0
f = h5py.File('../randomforest_results_wg.h5', 'w')

test_count = len(senaryo['test_sets'])
TPMAT = numpy.zeros((test_count, alphaStep))
FPMAT = numpy.zeros((test_count, alphaStep))
train_set = senaryo['train_set']
a = 0                                                           # Alpha test iterator
s_ite = 0
hasnopositives = 0
rf = ensemble.RandomForestClassifier(n_estimators=treeCount, random_state=(roc_iterator + 1) * 10)
rf.fit(train_set.data, numpy.ravel(train_set.labels))# Set iterator
for test_set in senaryo['test_sets']:
    #test_set = train_set
    posc = sum(test_set.labels == 1)
    if posc == 0:
        hasnopositives += 1
    totalpositives += posc

    p = rf.predict_proba(test_set.data)
    for alpha in alphaRange:
        pred_bias = numpy.array([1-alpha, alpha])
        results = calculate_accuracy(1, p, test_set.labels, bias=pred_bias)
        if posc==0 or results['tpnumber']==0:
            TPMAT[s_ite, a] = 0
        else:
            TPMAT[s_ite, a] = float(float(results['tpnumber']) / float(posc))

        FPMAT[s_ite, a] = results['fpnumber']
        a += 1
    s_ite += 1
    a = 0
    #note down the falses with given alpha
    pred_bias = numpy.array([1-analysefalseatalpha, analysefalseatalpha])
    results = calculate_accuracy(1, p, test_set.labels, bias=pred_bias)
    falses = results['falses']
    trues = results['trues']
    negatives = results['negatives']

    falsedset = f.create_dataset('falses_' + str(s_ite), shape=numpy.shape(falses), dtype='float')
    falsedset[:] = falses

    trueset = f.create_dataset('trues_' + str(s_ite), shape=numpy.shape(trues), dtype='float')
    trueset[:] = trues

    negset = f.create_dataset('negatives_' + str(s_ite), shape=numpy.shape(negatives), dtype='float')
    negset[:] = negatives

avg_tp_rate = numpy.sum(TPMAT, axis=0)
avg_tp_rate /= (test_count - hasnopositives)
avg_fp_number = numpy.sum(FPMAT, axis=0)
avg_fp_number /= test_count

merge_fp_tp = numpy.r_[avg_fp_number[None, :], avg_tp_rate[None, :]]
merge_fp_tp = merge_fp_tp.transpose()
dset = f.create_dataset('roc_vals', shape=numpy.shape(merge_fp_tp), dtype='float')
dset[:] = merge_fp_tp
f.close()

#print 'Mult. : ', mult
print 'TreeCount :', treeCount
for x in range(0, alphaStep-1):
        print 'Alpha : ', format(alphaRange[x], '.3f'), '& TP : ', format(avg_tp_rate[x], '.3f'), \
              '& FP : &', format(avg_fp_number[x], '.3f')


