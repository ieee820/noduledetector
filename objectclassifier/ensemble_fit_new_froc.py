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
alphaStart = 0.1
alphaStop = 0.6
alphaRange = numpy.linspace(alphaStart, alphaStop, alphaStep)
treeCount = 100
roc_iterator = 0
random_seed = 1
numpy.random.seed(random_seed)

analysefalseatalpha = 0.5
analyseatset = 1

totalpositives = 0
f = h5py.File('../copeat3.h5', 'w')

test_count = len(senaryo['test_sets'])
TPMAT = numpy.zeros((test_count, alphaStep))
FPMAT = numpy.zeros((test_count, alphaStep))
train_set = senaryo['train_set']
a = 0                                                           # Alpha test iterator
s_ite = 0

rf = ensemble.RandomForestClassifier(n_estimators=treeCount, random_state=(roc_iterator + 1) * 10)
rf.fit(train_set.data, numpy.ravel(train_set.labels))# Set iterator
predictions = []
labels_for_predictions = []
for test_set in senaryo['test_sets']:
    p = rf.predict_proba(test_set.data)
    predictions.extend(p[:, 1])
    labels_for_predictions.extend(zip(*test_set.labels)[0])

merge_fp_tp = numpy.array((predictions, labels_for_predictions))
merge_fp_tp = merge_fp_tp.transpose()
dset = f.create_dataset('p_vals', shape=numpy.shape(merge_fp_tp), dtype='float')
dset[:] = merge_fp_tp
f.close()

