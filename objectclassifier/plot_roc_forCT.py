import h5py
from FeatureSet import FeatureSet
from accurancyTools import *
from sklearn import ensemble
import matplotlib.pyplot as plt

trainingDataSetNames = ['Volume', 'CentroidNorm', 'Centroid', 'Perimeter', 'PseudoRadius', 'Complexity',
                        'BoundingBox2Volume', 'BoundingBoxAspectRatio', 'IntensityMax', 'IntensityMean',
                        'IntensityMin', 'IntensityStd', 'CloseMassRatio']

senaryo1File = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/Senaryo1/all_features.h5'
senaryo1LabelFile = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/Senaryo1/all_features_labels.h5'
senaryo1BatchFile = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/example_01_features.h5'
senaryo1BatchLabelFile = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/Labels/example_01_features.h5'
senaryo1 = {'all_features': senaryo1File, 'all_features_labels': senaryo1LabelFile, 'batch_features': senaryo1BatchFile, 'batch_features_labels': senaryo1BatchLabelFile}
senaryo1_train_sets = FeatureSet.readFromFile(senaryo1File, trainingDataSetNames, senaryo1LabelFile, 'labels')
senaryo1_batch_sets = FeatureSet.readFromFile(senaryo1BatchFile, trainingDataSetNames, senaryo1BatchLabelFile, 'labels')
senaryo1_sets = {'all_features_set': senaryo1_train_sets, 'batch_features_set': senaryo1_batch_sets, 'fileName': 'example01'}

senaryo2File = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/Senaryo2/all_features.h5'
senaryo2LabelFile = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/Senaryo2/all_features_labels.h5'
senaryo2BatchFile = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/example_02_features.h5'
senaryo2BatchLabelFile = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/Labels/example_02_features.h5'
senaryo2 = {'all_features': senaryo2File, 'all_features_labels': senaryo2LabelFile, 'batch_features': senaryo2BatchFile, 'batch_features_labels': senaryo2BatchLabelFile}
senaryo2_train_sets = FeatureSet.readFromFile(senaryo2File, trainingDataSetNames, senaryo2LabelFile, 'labels')
senaryo2_batch_sets = FeatureSet.readFromFile(senaryo2BatchFile, trainingDataSetNames, senaryo2BatchLabelFile, 'labels')
senaryo2_sets = {'all_features_set': senaryo2_train_sets, 'batch_features_set': senaryo2_batch_sets, 'fileName': 'example02'}

senaryo3File = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/Senaryo3/all_features.h5'
senaryo3LabelFile = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/Senaryo3/all_features_labels.h5'
senaryo3BatchFile = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/example_05_features.h5'
senaryo3BatchLabelFile = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/Labels/example_05_features.h5'
senaryo3 = {'all_features': senaryo3File, 'all_features_labels': senaryo3LabelFile, 'batch_features': senaryo3BatchFile, 'batch_features_labels': senaryo3BatchLabelFile}
senaryo3_train_sets = FeatureSet.readFromFile(senaryo3File, trainingDataSetNames, senaryo3LabelFile, 'labels')
senaryo3_batch_sets = FeatureSet.readFromFile(senaryo3BatchFile, trainingDataSetNames, senaryo3BatchLabelFile, 'labels')
senaryo3_sets = {'all_features_set': senaryo3_train_sets, 'batch_features_set': senaryo3_batch_sets, 'fileName': 'example05'}

senaryo4File = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/Senaryo4/all_features.h5'
senaryo4LabelFile = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/Senaryo4/all_features_labels.h5'
senaryo4BatchFile = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/example_03_features.h5'
senaryo4BatchLabelFile = '/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/FeatureFiles/Labels/example_03_features.h5'
senaryo4 = {'all_features': senaryo4File, 'all_features_labels': senaryo4LabelFile, 'batch_features': senaryo4BatchFile, 'batch_features_labels': senaryo4BatchLabelFile}
senaryo4_train_sets = FeatureSet.readFromFile(senaryo4File, trainingDataSetNames, senaryo4LabelFile, 'labels')
senaryo4_batch_sets = FeatureSet.readFromFile(senaryo4BatchFile, trainingDataSetNames, senaryo4BatchLabelFile, 'labels')
senaryo4_sets = {'all_features_set': senaryo4_train_sets, 'batch_features_set': senaryo4_batch_sets, 'fileName': 'example03'}

all_senaryo_files = [senaryo1, senaryo2, senaryo3, senaryo4]
all_senaryo_sets = [senaryo1_sets, senaryo2_sets, senaryo3_sets, senaryo4_sets]

alphaStep = 25
alphaStart = 0.5
alphaStop = 1.0
treeCount = 10
mult = 20.0
alphaRange = numpy.linspace(alphaStart, alphaStop, alphaStep)
random_seed = 100
numpy.random.seed(random_seed)
roc_iterator = 0
TPMAT = numpy.zeros((all_senaryo_sets.__len__(), alphaStep))
FPMAT = numpy.zeros((all_senaryo_sets.__len__(), alphaStep))
s = 0
a = 0

f = h5py.File('/Users/ilker/Desktop/Thesis/Anode09-Original-Prediction/GUIResultsCalc/randomforest_results.h5', 'w')
for senaryo in all_senaryo_sets:
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
        TPMAT[s][a] = set_test_results['tprate']
        FPMAT[s][a] = set_test_results['fpnumber']
        a += 1
    dataset = f.create_dataset(senaryo['fileName'], numpy.shape(p), dtype='float')
    dataset[:] = p
    roc_iterator += 1
    s += 1
    a = 0
avg_tp_rate = numpy.sum(TPMAT, axis=0) / len(all_senaryo_sets)
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
print 'Mult : ', mult
print 'TreeCount :', treeCount
print 'Alpha : ', alphaRange[0], '& TP : ', avg_tp_rate[0], '& FP : &', avg_fp_number[0]
print 'Alpha : ', alphaRange[6], '& TP : ', avg_tp_rate[6], '& FP : &', avg_fp_number[6]
print 'Alpha : ', alphaRange[24], '& TP : ', avg_tp_rate[24],'& FP : &', avg_fp_number[24]