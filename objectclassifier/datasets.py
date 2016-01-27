from FeatureSet import FeatureSet
import numpy

def get_sets(training_dataset_names):

    # Test Set Generation
    sets = ['2', '1']
    test = [None] * sets.__len__()
    test_labels = [None] * sets.__len__()
    batch_sets = [None] * sets.__len__()
    for x in range(sets.__len__()):
        test[x] = '../../noduledetectordata/test_train_sets/test_feas_' + sets[x] + '.h5'
        test_labels[x] = '../../noduledetectordata/test_train_sets/test_labels_' + sets[x] + '.h5'
        batch_sets[x] = FeatureSet.readFromFile(test[x], training_dataset_names, test_labels[x], 'labels')

    # Train Set
    train = '../../noduledetectordata/test_train_sets/train_feas.h5'
    train_labels = '../../noduledetectordata/test_train_sets/train_labels.h5'
    train_set = FeatureSet.readFromFile(train, training_dataset_names, train_labels, 'labels')
    senaryo_sets = {'train_set': train_set, 'test_sets': batch_sets}

    return senaryo_sets