/* file: train_batch.cpp */
/*******************************************************************************
* Copyright 2014-2018 Intel Corporation.
*
* This software and the related documents are Intel copyrighted  materials,  and
* your use of  them is  governed by the  express license  under which  they were
* provided to you (License).  Unless the License provides otherwise, you may not
* use, modify, copy, publish, distribute,  disclose or transmit this software or
* the related documents without Intel's prior written permission.
*
* This software and the related documents  are provided as  is,  with no express
* or implied  warranties,  other  than those  that are  expressly stated  in the
* License.
*******************************************************************************/

/* DO NOT EDIT THIS FILE - it is machine generated */
#include <jni.h>/* Header for class com_intel_daal_algorithms_weak_learner_training_TrainingResult */

#include "daal.h"
#include "weak_learner/training/JTrainingBatch.h"

using namespace daal;
using namespace daal::data_management;
using namespace daal::algorithms;
using namespace daal::services;

#include "train_types.i"

/*
 * Class:     com_intel_daal_algorithms_weak_learner_training_TrainingBatch
 * Method:    cGetResult
 * Signature:(J)J
 */
JNIEXPORT jlong JNICALL Java_com_intel_daal_algorithms_weak_1learner_training_TrainingBatch_cGetResult
(JNIEnv *env, jobject thisObj, jlong algAddr)
{
    SerializationIfacePtr *ptr = new SerializationIfacePtr();

    SharedPtr<wl_tr_of> alg = staticPointerCast<wl_tr_of, AlgorithmIface>(*(SharedPtr<AlgorithmIface> *)algAddr);
    *ptr = alg->getResult();

    return (jlong)ptr;
}