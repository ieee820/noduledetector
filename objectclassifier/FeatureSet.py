# -*- coding: utf-8 -*-
"""
Created on Mon Sep 16 01:24:51 2013

@author: btek
"""

import numpy
import h5py

class FeatureSet(object):
    @staticmethod
    def readFromFile(featureFile, featureDataSet,labelFile=None, labelDataSet=None, ignoreDataZero = False):
    # label file is one
        if labelFile != None:
            print labelFile
            h5file = h5py.File(labelFile, 'r')
            print labelDataSet
            h5data = h5file[labelDataSet]
            rowlength = len(h5data)
            print "Number of samples", rowlength

            labels = numpy.zeros([rowlength,1], dtype=numpy.uint32)
            labels[:,0] = numpy.uint32((h5data[...]))
            h5file.close()
            print "Unique labels", numpy.unique(labels)


        else:
            # LABEL FILE YOKSA ROW LENGTH VOLUMEDAN AL
            h5file = h5py.File(featureFile, 'r')
            h5data = h5file['Volume']
            print "Reading from label"
            rowlength = len(h5data)
            print rowlength
            h5file.close()

        if ignoreDataZero:
            dataStartIndex = 1
            print "WARNING LABEL ZERO IS NOT READ!"
        else:
            dataStartIndex = 0

        h5file = h5py.File(featureFile, 'r')
        featureNames = numpy.copy(featureDataSet)
        ix = 0
        for t in featureDataSet:
            print "Feature DataSet", ix, "Name=", t, '\n'

            fDataSet= h5file[t]
            dsetShape = fDataSet.shape
            dsetDims = len(dsetShape)

            if(dsetShape[dsetDims-1]== rowlength):
                newfeaturecolumns =fDataSet[...,dataStartIndex:] 
            else:
                # if it is not the last one must be the first one
                newfeaturecolumns =fDataSet[dataStartIndex:,...] 
                
            if(numpy.any(numpy.isnan(newfeaturecolumns))):
                print numpy.nonzero(numpy.isnan(newfeaturecolumns))
            
            fdim = newfeaturecolumns.ndim
            siz  = numpy.array(numpy.shape(newfeaturecolumns))                
            
            if(fdim ==1):
                 newfeaturecolumns = numpy.reshape(newfeaturecolumns, [siz[0],1])
                    
            
            print "dataSet Dims = ", fdim, ", Shape = ", siz,'\n'
            #dim0 = siz[0]
            #if size is not correct transpose it
            
            if((fdim==2) & (siz[0]!=rowlength)):
                print "transposing", siz, " shaped columns"
                newfeaturecolumns = numpy.transpose(newfeaturecolumns)
                siz = numpy.shape(newfeaturecolumns)
                #print "new size", siz, '\n'
            elif(fdim>2):
                #print "data shape", siz
                flatsize = numpy.prod(siz[siz!=rowlength])
                #print "reshaping", siz, " shaped columns into",rowlength,"x", flatsize,'\n'
                newfeaturecolumns = numpy.reshape(newfeaturecolumns, [rowlength,flatsize])
                siz = numpy.shape(newfeaturecolumns)
                #print "new size", siz, '\n'
            
            siz = numpy.shape(newfeaturecolumns)
            if (ix==0):
                data =  newfeaturecolumns
                featureIndexes = numpy.zeros([siz[0],1],'uint32')
                featureIndexes[:] = ix
            else:
#                print "Adding columns with shape=", numpy.shape(newfeaturecolumns)
 #               print " to Data shape=",numpy.shape(data),'\n'
                data = numpy.concatenate([data, newfeaturecolumns],axis=1)
                ty = numpy.ones([siz[0],siz[1]],'uint32')
                #print numpy.shape(featureIndexes)
                featureIndexes= numpy.concatenate([featureIndexes, ty], axis=1 )
            ix+= 1
            
            nanIx = numpy.isnan(newfeaturecolumns)
            if (numpy.any(nanIx)):
                print(t+' has NaNs')

            if data.dtype != numpy.float32:
                print("Warning converting data to float32")
                data = numpy.float32(data)
        
        h5file.close()
        sampleIndex = numpy.uint32(range(0, rowlength))
        
        if labelFile != None:
            return FeatureSet(data, labels, sampleIndex, featureIndexes, featureNames)
        else:
            return FeatureSet(data, None, sampleIndex, featureIndexes, featureNames)
                
    def __init__(self, data, labels, sampleIndex=None, featureNames=None, featureIndexes=None ):
        # create structure
        self.data = data
        #self.index  
        self.labels = labels
        self.classLabels = numpy.unique(labels)
        self.numClass = len(self.classLabels)
        self.featureIndexes = featureIndexes
        self.featureNames = featureNames
        self.sampleNum = numpy.size(data, 0)
        self.featureNum = numpy.size(data, 1)
        self.sampleIndex = sampleIndex
        print 'Shapes ', numpy.shape(labels), numpy.shape(self.data)
      
        # this always refers to original configuration
        
    def divideSetRandom(self, ratio1, ratio2,randomize=None ,verbose=False):
        sampleIndex = self.sampleIndex
        sampleNum = len(sampleIndex) 
        firstPart = range(0, int(ratio1*sampleNum/float(ratio1+ratio2)))
        
        secondPart = range(int(ratio1*sampleNum/float(ratio1+ratio2)), sampleNum)
        if randomize is None:
            indexes =sampleIndex           
        else:
            indexes= numpy.random.permutation(sampleNum)
            indexes = sampleIndex[indexes]
        index1 = indexes[firstPart]       
        data1 = self.data[index1,:]
        label1 = self.labels[index1]
        
        index2 = indexes[secondPart]       
        data2 = self.data[index2,:]
        label2 = self.labels[index2]
        f1 = FeatureSet(data1,label1,index1, self.featureNames,self.featureIndexes)
        f2 = FeatureSet(data2,label2,index2, self.featureNames,self.featureIndexes)
        if(verbose):
            print "Input feature set of ", sampleNum, " rows is divided into two parts:", len(index1), " and ", len(index2), " samples" ,"\n"
            print "part 1 has ", numpy.sum(label1>0),"positive and", numpy.sum(label1==0),"negative sampples"
            print "part 2 has ", numpy.sum(label2>0),"positive and", numpy.sum(label2==0),"negative sampples"
        return f1,f2

## this method returns sample distribution for different classes among dataset        
    def getSampleDist(self):
        nClasses = self.numClass
        distClasses = numpy.zeros([nClasses, 1], dtype=int)
        for s in self.labels:
            distClasses[s]+=1
        return distClasses
        
    def getSamplesbyIndx(self, index):

        data1 = self.data[index,:]
        label1 = self.labels[index]
        f1 = FeatureSet(data1,label1,index, self.featureNames,self.featureIndexes)
        return f1
        
## this method balances sample distributions
    def balanceOnLabel(self,pref = None, multiplier= 1):
        
        sampleIndex = self.sampleIndex
        distClasses = self.getSampleDist()

        if pref==None:
            print "this method balances sample numbers for least populated class"
            # we found the class which has the minimum elements
            minClassIndex = numpy.argmin(distClasses)
        else:
            minClassIndex = pref
            
        k = distClasses[minClassIndex]
        minClassSampleIndx = numpy.squeeze(self.labels ==minClassIndex)
        print "Choosing ", k, "samples from",numpy.shape(minClassSampleIndx)
        # now from each other class not minClassIndex we will take k*multiplier samples
        newIndx = sampleIndex[minClassSampleIndx]
        print "#Negatives = ",len(newIndx) 
        newData = self.data[minClassSampleIndx,:]
        newLabel = self.labels[minClassSampleIndx]
        
        for c in self.classLabels:
            
            if c==minClassIndex:
                continue
            else:
                #print c
                allSampleIndex = numpy.squeeze(numpy.nonzero(numpy.squeeze(self.labels==c)))
                #print numpy.shape(self.labels==c),numpy.shape(allSampleIndex),"lslslsl"
                cSampleIndex = numpy.random.choice(allSampleIndex,k*multiplier,False)
            
                newIndx = numpy.concatenate((newIndx, sampleIndex[cSampleIndex]))
                newData = numpy.concatenate((newData, self.data[cSampleIndex,:]))
                newLabel =numpy.concatenate((newLabel, self.labels[cSampleIndex]))
        
        #print numpy.shape(newIndx),numpy.shape(newData),numpy.shape(newLabel)
        f1 = FeatureSet(newData,newLabel,newIndx, self.featureNames,self.featureIndexes)
        
        return f1

            # select k samples of this label

    def divideSetByZ(self,coordinateZ, verbose=False):

        # experiments concerning different data divisions. 
        # 1 take z<128 as it was done in first ilastik training
        # matlab coordinates 
        #zInRoi = coordinateZ-1<=128
        #this is too week, 92.7-13.7
        
        # 2 take z<128 as it was done in first ilastik training
        # matlab coordinates 
        b = 128
        k = 256
        tol = 10
        #zInRoi = coordinateZ-1<=b
        coordinateZ = coordinateZ.astype('int')
        zmax = int(numpy.max(coordinateZ))
        zrange = numpy.array(range(b,zmax-tol,k))
        zSet  = numpy.array(range(0,b,1))
        for zp in zrange:
            zrangelow = zp-tol
            zrangehigh = zp
            #print zrangelow, zrangehigh,
            zSet = numpy.concatenate((zSet, numpy.array(range(zrangelow, zrangehigh,1))),0 )
        #this is too week, 92.7-13.7
       
        
        zInRoi = numpy.in1d(coordinateZ, zSet)
        #print (zInRoi[1:10])
        
        sampleIndex = self.sampleIndex
        sampleNum = len(sampleIndex) 
        # choose, 
        
        secondPart = zInRoi==False
        
        indexes =sampleIndex
        index1 = indexes[zInRoi]
        data1 = self.data[index1,:]
        label1 = self.labels[index1]
        
        index2 = indexes[secondPart]       
        data2 = self.data[index2,:]
        label2 = self.labels[index2]
        f1 = FeatureSet(data1,label1,index1, self.featureNames,self.featureIndexes)
        f2 = FeatureSet(data2,label2,index2, self.featureNames,self.featureIndexes)
        if(verbose):
            print "Input feature set of ", sampleNum, " rows is divided into two parts:", len(index1), " and ", len(index2), " samples" ,"\n"
            print "part 1 has ", numpy.sum(label1==1),"positive and", numpy.sum(label1==0),"negative sampples"
            print "part 2 has ", numpy.sum(label2==1),"positive and", numpy.sum(label2==0),"negative sampples"
        return f1,f2