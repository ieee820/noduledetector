import os
from sklearn import ensemble
from datasets import *


trainingDataSetNames = ['Volume', 'PseudoRadius', 'Complexity',
    'BoundingBox2Volume', 'BoundingBoxAspectRatio', 'IntensityMax',
    'IntensityMin', 'CloseMassRatio', 'IntensityHist',
    'gaussfit', 'Gradient', 'GradientOfMag']

senaryo = get_anode_sets(trainingDataSetNames)

treeCount = 100
iteration = 0
random_s = 10
random_seed = 5
numpy.random.seed(random_seed)

if os.path.isfile('Output.txt'):
    os.remove('Output.txt')

text_file = open("Output.txt", "w")

train_set = senaryo['train_set']
rf = ensemble.RandomForestClassifier(n_estimators=treeCount, random_state=random_s)
rf.fit(train_set.data, numpy.ravel(train_set.labels))       # Train once

for test_set in senaryo['test_sets']:
    p = rf.predict_proba(test_set.data)
    nodules = p[:, 1]                                       # Get only nodules predictions
    centroids = test_set.centroid
    # Writing Them to file
    for i in range(0, len(nodules)):
        # Look once more to the centroids index
        text_file.write('test%02d %d %d %d %f\n' % (iteration+1, centroids[i, 0]-1, centroids[i, 1]-1, centroids[i, 2]-1, nodules[i]))

    iteration += 1

text_file.close()
