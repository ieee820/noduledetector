# -*- coding: utf-8 -*-
"""
Created on Mon Sep 16 01:29:44 2013

@author: btek
"""
import numpy


def calculateAccuracy(pred, th, gt, labels=None, verbose=False):
    pred = numpy.squeeze(pred)
    gt = numpy.squeeze(gt)
    if labels is None:
        labels = [0, 1]
    positiveDT = pred >= th
    numPositiveDT = sum(positiveDT)

    positiveGT = gt == labels[1]
    negativeGT = gt == labels[0]
    numPositiveGT = sum(positiveGT)
    if (verbose):
        print "Positive GT =", numPositiveGT, "Negative GT = ", len(gt) - numPositiveGT
        print "Positive DT =", numPositiveDT, "Negative DT = ", len(pred) - numPositiveDT

    truePositive = (positiveDT == 1) & positiveGT
    sumTruePositive = sum(truePositive)
    falsePositive = (positiveDT == 1) & negativeGT
    sumFalsePositive = sum(falsePositive)
    if (verbose):
        print "True Positive =", sumTruePositive, "False Positive = ", sumFalsePositive
    results = numpy.array(
        [sumTruePositive / float(numPositiveGT), sumFalsePositive, sumTruePositive / float(numPositiveDT)])
    # results = numpy.array([sumTruePositive/float(numPositiveGT), sumFalsePositive])
    return results


def calculateArgMax(predprob, bias):
    predprob = numpy.squeeze(predprob)
    s1, s2 = numpy.shape(predprob)
    if s1 < s2:
        predprob = numpy.transpose(predprob)
    print "Prediction matrix shape=", numpy.shape(predprob)
    print "prediction bias", bias
    if bias is None:
        predictionlabels = numpy.argmax(predprob, 1)
    else:
        predictionlabels = numpy.argmax(predprob * bias, 1)
        # testthis = predprob*bias
        # print(testthis[1:4,:])
        # print(predprob[1:4,:])

    return predictionlabels


def calculateBinaryDecisionAccuracyforMultiClass(pred, gt, labels=None, verbose=False, bias=None):
    if labels is None:
        labels = numpy.unique(gt)
        print "unique labels=", labels

    predictionMaximum = calculateArgMax(pred, bias)
    # binary decision 0 background, 1 object
    predictionLabels = predictionMaximum

    gt = numpy.squeeze(gt)

    nclasses = len(labels)
    # print predictionlabels

    acc = numpy.zeros(nclasses + 1)
    for c in range(nclasses):
        lab = labels[c]

        if c == 0:
            truepos = numpy.logical_and(gt == lab, predictionLabels == 0)
        else:
            truepos = numpy.logical_and(gt == lab, predictionLabels == 1)

        acc[c + 1] = int((sum(truepos) / float(sum(gt == lab))) * 100) / 100.0
        print "class ", lab, " has ", sum(gt == lab), " hit%= ", acc[c + 1], " miss #= ", (1 - acc[c + 1]) * sum(
            gt == lab)

    acc[0] = sum((gt > 0) & (predictionLabels == 1)) / float(sum(gt > 0))

    return acc

def calculate_accuracy(class_no, pred, gt, labels=None, bias=None):
    # This function calculates tprate and fp count for given bias value at given class
    if labels is None:
        labels = numpy.unique([0, 1])

    predictionMaximum = calculateArgMax(pred, bias)
    predictionLabels = numpy.zeros(numpy.shape(predictionMaximum))
    for i in range(len(predictionMaximum)):
        predictionLabels[i] = labels[predictionMaximum[i]]
    gt = numpy.squeeze(gt)
    data = {'tprate': 0.0, 'fpnumber': 0}

    tpos = 0
    fpos = 0
    falses = []
    trues = []
    negatives = []
    for i in range(len(predictionLabels)):
        predicted = int(predictionLabels[i])
        reallabel = gt[i]
        if predicted==1 and (reallabel==1):
            tpos += 1
            trues.append(i+1)

        if predicted==0 and reallabel==1:
            negatives.append(i+1)

        if predicted==1 and reallabel==0:
            falses.append(i+1) #note down the false
            fpos += 1

    data['tpnumber'] = tpos
    data['fpnumber'] = fpos

    data['falses'] = falses
    data['trues'] = trues
    data['negatives'] = negatives
    #lab = labels[class_no]
    #truepos = numpy.logical_and(gt == lab, predictionLabels == lab)
    #falsepos = numpy.logical_and(gt != lab, predictionLabels == lab)
    #data['tpnumber'] = int((sum(truepos)))
    #data['tprate'] = int((sum(truepos) / float(sum(gt == lab))) * 100) / 100.0
    #data['fpnumber'] = sum(falsepos)
    return data

def calculateAccuracyN(pred, gt, labels=None, verbose=False, bias=None):
    # Calculates accuracy for N=2,3,... class classification
    # we assume 'pred' has probabilities. 
    # arg max is the winner class, no threshold,
    # however you can scale one class probability with a bias value
    # for example bias = [1, 1, 1.2] scales prediction prob of label==2    

    if labels is None:
        labels = numpy.unique(gt)
        print "unique labels=", labels

    predictionMaximum = calculateArgMax(pred, bias)
    predictionLabels = numpy.zeros(numpy.shape(predictionMaximum))
    for i in range(len(predictionMaximum)):
        predictionLabels[i] = labels[predictionMaximum[i]]

    gt = numpy.squeeze(gt)

    nclasses = len(labels)
    data = {'tprate': 0.0, 'fpnumber': 0}

    # print predictionlabels

    acc = numpy.zeros(nclasses * 2 + 3)
    for c in range(nclasses):
        lab = labels[c]
        truepos = numpy.logical_and(gt == lab, predictionLabels == lab)
        falsepos = numpy.logical_and(gt != lab, predictionLabels == lab)
        # true positive rate for class c 
        print "class ", c, " has ", sum(gt == lab), " samples"
        acc[2 * c + 1] = int((sum(truepos) / float(sum(gt == lab))) * 100) / 100.0
        data['tpnumber'] = int((sum(truepos)))
        data['tprate'] = acc[2 * c + 1]
        data['fpnumber'] = sum(falsepos)
        # positive prediction value for class c
        acc[2 * c + 2] = int(sum(truepos) / float((sum(truepos) + sum(falsepos)) + 0.01) * 100) / 100.0

        acc[2 * c + 3] = sum(falsepos)
        print "False positive :", sum(falsepos)
        print "True positive :", sum(truepos)

    acc[0] = sum(gt == predictionLabels) / float(len(gt))

    if verbose:
        for c in range(nclasses):
            print "Class =", c, " TP =", acc[2 * c + 1]
            print "Class =", c, " PPV =", acc[2 * c + 2]
        print "Overall ACC ", acc[0]

    return data  # acc
