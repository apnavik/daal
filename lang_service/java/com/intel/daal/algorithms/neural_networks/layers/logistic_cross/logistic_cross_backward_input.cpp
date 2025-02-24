/* file: logistic_cross_backward_input.cpp */
/*******************************************************************************
* Copyright 2014-2019 Intel Corporation
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*******************************************************************************/

#include <jni.h>
#include "com_intel_daal_algorithms_neural_networks_layers_logistic_cross_LogisticCrossBackwardInput.h"

#include "daal.h"

#include "common_helpers.h"

#include "com_intel_daal_algorithms_neural_networks_layers_logistic_cross_LogisticCrossLayerDataId.h"
#define auxDataId        com_intel_daal_algorithms_neural_networks_layers_logistic_cross_LogisticCrossLayerDataId_auxDataId
#define auxGroundTruthId com_intel_daal_algorithms_neural_networks_layers_logistic_cross_LogisticCrossLayerDataId_auxGroundTruthId

USING_COMMON_NAMESPACES()
using namespace daal::algorithms::neural_networks::layers::loss::logistic_cross;

/*
 * Class:     com_intel_daal_algorithms_neural_networks_layers_logistic_cross_LogisticCrossBackwardInput
 * Method:    cSetInput
 * Signature: (JIJ)V
 */
JNIEXPORT void JNICALL Java_com_intel_daal_algorithms_neural_1networks_layers_logistic_1cross_LogisticCrossBackwardInput_cSetInput
  (JNIEnv *env, jobject thisObj, jlong inputAddr, jint id, jlong ntAddr)
{
    if (id == auxGroundTruthId || id == auxDataId)
    {
        jniInput<backward::Input>::set<LayerDataId, Tensor>(inputAddr, id, ntAddr);
    }
}

/*
 * Class:     com_intel_daal_algorithms_neural_networks_layers_logistic_cross_LogisticCrossBackwardInput
 * Method:    cGetInput
 * Signature: (JI)J
 */
JNIEXPORT jlong JNICALL Java_com_intel_daal_algorithms_neural_1networks_layers_logistic_1cross_LogisticCrossBackwardInput_cGetInput
  (JNIEnv *env, jobject thisObj, jlong inputAddr, jint id)
{
    if (id == auxGroundTruthId || id == auxDataId)
    {
        return jniInput<backward::Input>::get<LayerDataId, Tensor>(inputAddr, id);
    }

    return (jlong)0;
}
