import h5py
from FeatureSet import FeatureSet
from accurancyTools import *
from sklearn import ensemble
import matplotlib.pyplot as plt

trainingDataSetNames = ['Volume', 'CentroidNorm', 'Centroid', 'Perimeter', 'PseudoRadius', 'Complexity',
                        'BoundingBox2Volume', 'BoundingBoxAspectRatio', 'IntensityMax', 'IntensityMean',
                        'IntensityMin', 'IntensityStd', 'IntensityHist', 'gaussianCoefficients',
                        'gaussianGOF', 'gaussianGOV']

senaryo1File = '../../noduledetectordata/ilastikoutput3/s1/s1.h5'
senaryo1LabelFile = '../../noduledetectordata/ilastikoutput3/s1/s1_labels.h5'
senaryo1BatchFile = '../../noduledetectordata/ilastikoutput3/s1/example_05.h5'
senaryo1BatchLabelFile = '../../noduledetectordata/ilastikoutput3/s1/labels_example_05.h5'
senaryo1 = {'all_features': senaryo1File, 'all_features_labels': senaryo1LabelFile, 'batch_features': senaryo1BatchFile, 'batch_features_labels': senaryo1BatchLabelFile}
senaryo1_train_sets = FeatureSet.readFromFile(senaryo1File, trainingDataSetNames, senaryo1LabelFile, 'labels')
senaryo1_batch_sets = FeatureSet.readFromFile(senaryo1BatchFile, trainingDataSetNames, senaryo1BatchLabelFile, 'labels')
senaryo1_sets = {'all_features_set': senaryo1_train_sets, 'batch_features_set': senaryo1_batch_sets, 'fileName': 'example05'}

senaryo2File = '../../noduledetectordata/ilastikoutput3/s2/s2.h5'
senaryo2LabelFile = '../../noduledetectordata/ilastikoutput3/s2/s2_labels.h5'
senaryo2BatchFile = '../../noduledetectordata/ilastikoutput3/s2/example_01.h5'
senaryo2BatchLabelFile = '../../noduledetectordata/ilastikoutput3/s2/labels_example_01.h5'
senaryo2 = {'all_features': senaryo2File, 'all_features_labels': senaryo2LabelFile, 'batch_features': senaryo2BatchFile, 'batch_features_labels': senaryo2BatchLabelFile}
senaryo2_train_sets = FeatureSet.readFromFile(senaryo2File, trainingDataSetNames, senaryo2LabelFile, 'labels')
senaryo2_batch_sets = FeatureSet.readFromFile(senaryo2BatchFile, trainingDataSetNames, senaryo2BatchLabelFile, 'labels')
senaryo2_sets = {'all_features_set': senaryo2_train_sets, 'batch_features_set': senaryo2_batch_sets, 'fileName': 'example01'}

senaryo3File = '../../noduledetectordata/ilastikoutput3/s3/s3.h5'
senaryo3LabelFile = '../../noduledetectordata/ilastikoutput3/s3/s3_labels.h5'
senaryo3BatchFile = '../../noduledetectordata/ilastikoutput3/s3/example_03.h5'
senaryo3BatchLabelFile = '../../noduledetectordata/ilastikoutput3/s3/labels_example_03.h5'
senaryo3 = {'all_features': senaryo3File, 'all_features_labels': senaryo3LabelFile, 'batch_features': senaryo3BatchFile, 'batch_features_labels': senaryo3BatchLabelFile}
senaryo3_train_sets = FeatureSet.readFromFile(senaryo3File, trainingDataSetNames, senaryo3LabelFile, 'labels')
senaryo3_batch_sets = FeatureSet.readFromFile(senaryo3BatchFile, trainingDataSetNames, senaryo3BatchLabelFile, 'labels')
senaryo3_sets = {'all_features_set': senaryo3_train_sets, 'batch_features_set': senaryo3_batch_sets, 'fileName': 'example03'}

senaryo4File = '../../noduledetectordata/ilastikoutput3/s4/s4.h5'
senaryo4LabelFile = '../../noduledetectordata/ilastikoutput3/s4/s4_labels.h5'
senaryo4BatchFile = '../../noduledetectordata/ilastikoutput3/s4/example_02.h5'
senaryo4BatchLabelFile = '../../noduledetectordata/ilastikoutput3/s4/labels_example_02.h5'
senaryo4 = {'all_features': senaryo4File, 'all_features_labels': senaryo4LabelFile, 'batch_features': senaryo4BatchFile, 'batch_features_labels': senaryo4BatchLabelFile}
senaryo4_train_sets = FeatureSet.readFromFile(senaryo4File, trainingDataSetNames, senaryo4LabelFile, 'labels')
senaryo4_batch_sets = FeatureSet.readFromFile(senaryo4BatchFile, trainingDataSetNames, senaryo4BatchLabelFile, 'labels')
senaryo4_sets = {'all_features_set': senaryo4_train_sets, 'batch_features_set': senaryo4_batch_sets, 'fileName': 'example02'}

all_senaryo_files = [senaryo1, senaryo2, senaryo3, senaryo4]
all_senaryo_sets = [senaryo1_sets, senaryo2_sets, senaryo3_sets, senaryo4_sets]

alphaStep = 25
alphaStart = 0.5
alphaStop = 1.0
treeCount = 10
mult = 15.0
alphaRange = numpy.linspace(alphaStart, alphaStop, alphaStep)
random_seed = 100
numpy.random.seed(random_seed)
roc_iterator = 0
TPMAT = numpy.zeros((all_senaryo_sets.__len__(), alphaStep))
FPMAT = numpy.zeros((all_senaryo_sets.__len__(), alphaStep))
s = 0
a = 0

f = h5py.File('../randomforest_results_wg.h5', 'w')
allpositives = 0
for senaryo in all_senaryo_sets:
    allpositives += sum(senaryo['batch_features_set'].labels==1)
    avg_tp_rate = 0.0
    avg_fp_number = 0
    rf = ensemble.RandomForestClassifier(n_estimators=treeCount, random_state=(roc_iterator+1)*10)
    sde = senaryo['all_features_set'].balanceOnLabel(multiplier=mult)
    sample_weight = numpy.array([1/mult if i == 0 else 1.0 for i in sde.labels])
    rf.fit(sde.data, numpy.ravel(sde.labels), sample_weight)
    for x in range(0, treeCount):
        rf_ext = ensemble.RandomForestClassifier(n_estimators=treeCount, random_state=(roc_iterator+1)*10)
        sde = senaryo['all_features_set'].balanceOnLabel(multiplier=mult)
        sample_weight = numpy.array([1/mult if i == 0 else 1.0 for i in sde.labels])
        rf_ext.fit(sde.data, numpy.ravel(sde.labels), sample_weight)
        rf.estimators_.extend(rf_ext.estimators_)
        rf.n_estimators += rf_ext.n_estimators
    p = rf.predict_proba(senaryo['batch_features_set'].data)
    for alpha in alphaRange:
        predBias = numpy.array([1-alpha, alpha])
        set_test_results = calculateAccuracyN(p, senaryo['batch_features_set'].labels, bias=predBias, verbose=True)
        TPMAT[s][a] = set_test_results['tpnumber']
        #TPMAT[s][a] = set_test_results['tprate']
        FPMAT[s][a] = set_test_results['fpnumber']
        a += 1
    dataset = f.create_dataset(senaryo['fileName'], numpy.shape(p), dtype='float')
    dataset[:] = p
    roc_iterator += 1
    s += 1
    a = 0
avg_tp_rate = numpy.sum(TPMAT, axis=0) / allpositives
avg_fp_number = numpy.sum(FPMAT, axis=0) / len(all_senaryo_sets)
merge_fp_tp = numpy.r_[avg_fp_number[None, :], avg_tp_rate[None, :]]
merge_fp_tp = merge_fp_tp.transpose()
dset = f.create_dataset('roc_vals', shape=numpy.shape(merge_fp_tp), dtype='float')
dset[:] = merge_fp_tp
dset.attrs.create('var_mult', mult)
dset.attrs.create('var_treecount', treeCount)
dset.attrs.create('var_alphastep', alphaStep)
dset.attrs.create('var_alphastart', alphaStart)
dset.attrs.create('var_alphastop', alphaStop)
f.close()
print merge_fp_tp
print 'Mult. : ', mult
print 'TreeCount :', treeCount
for x in range(0, 24):
    print 'Alpha : ', alphaRange[x], '& TP : ', avg_tp_rate[x], '& FP : &', avg_fp_number[x]