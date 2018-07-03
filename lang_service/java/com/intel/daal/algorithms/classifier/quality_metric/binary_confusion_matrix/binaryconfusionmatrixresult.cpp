/* file: binaryconfusionmatrixresult.cpp */
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
#include <jni.h>
#include "daal.h"
#include "JComputeMode.h"
#include "classifier/quality_metric/binary_confusion_matrix/JBinaryConfusionMatrixResult.h"
#include "classifier/quality_metric/binary_confusion_matrix/JBinaryConfusionMatrixResultId.h"
#include "classifier/quality_metric/binary_confusion_matrix/JBinaryConfusionMatrixMethod.h"

#include "common_helpers.h"

#define ConfusionMatrix com_intel_daal_algorithms_classifier_quality_metric_binary_confusion_matrix_BinaryConfusionMatrixResultId_ConfusionMatrix
#define BinaryMetrics com_intel_daal_algorithms_classifier_quality_metric_binary_confusion_matrix_BinaryConfusionMatrixResultId_BinaryMetrics

USING_COMMON_NAMESPACES();
using namespace daal::algorithms::classifier::quality_metric;
using namespace daal::algorithms::classifier::quality_metric::binary_confusion_matrix;

/*
 * Class:     com_intel_daal_algorithms_classifier_quality_metric_binary_confusion_matrix_BinaryConfusionMatrixResult
 * Method:    cSetResultTable
 * Signature: (JIJ)V
 */
JNIEXPORT void
JNICALL Java_com_intel_daal_algorithms_classifier_quality_1metric_binary_1confusion_1matrix_BinaryConfusionMatrixResult_cSetResultTable
(JNIEnv *, jobject, jlong resAddr, jint id, jlong ntAddr)
{
    jniArgument<binary_confusion_matrix::Result>::set<binary_confusion_matrix::ResultId, NumericTable>(resAddr, id, ntAddr);
}

/*
 * Class:     com_intel_daal_algorithms_classifier_quality_metric_binary_confusion_matrix_BinaryConfusionMatrixResult
 * Method:    cGetResultTable
 * Signature: (JI)J
 */
JNIEXPORT jlong
JNICALL Java_com_intel_daal_algorithms_classifier_quality_1metric_binary_1confusion_1matrix_BinaryConfusionMatrixResult_cGetResultTable
(JNIEnv *, jobject, jlong resAddr, jint id)
{
    if (id == ConfusionMatrix)
    {
        return jniArgument<binary_confusion_matrix::Result>::get<binary_confusion_matrix::ResultId, NumericTable>(resAddr, confusionMatrix);
    } else if (id == BinaryMetrics)
    {
        return jniArgument<binary_confusion_matrix::Result>::get<binary_confusion_matrix::ResultId, NumericTable>(resAddr, binaryMetrics);
    }

    return (jlong)0;

}

JNIEXPORT jlong JNICALL
Java_com_intel_daal_algorithms_classifier_quality_1metric_binary_1confusion_1matrix_BinaryConfusionMatrixResult_cNewResult
(JNIEnv *, jobject)
{
    return jniArgument<binary_confusion_matrix::Result>::newObj();
}