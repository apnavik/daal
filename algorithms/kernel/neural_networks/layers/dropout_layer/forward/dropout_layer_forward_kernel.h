/* file: dropout_layer_forward_kernel.h */
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

//++
//  Implementation of the forward dropout layer
//--


#ifndef __DROPOUT_LAYER_FORWARD_KERNEL_H__
#define __DROPOUT_LAYER_FORWARD_KERNEL_H__

#include "neural_networks/layers/dropout/dropout_layer.h"
#include "neural_networks/layers/dropout/dropout_layer_types.h"
#include "kernel.h"
#include "numeric_table.h"
#include "service_math.h"
#include "service_numeric_table.h"
#include "bernoulli_kernel.h"

using namespace daal::data_management;
using namespace daal::services;

namespace daal
{
namespace algorithms
{
namespace neural_networks
{
namespace layers
{
namespace dropout
{
namespace forward
{
namespace internal
{
/**
 *  \brief Kernel for dropout calculation
 */
template<typename algorithmFPType, Method method, CpuType cpu>
class DropoutKernel : public Kernel
{
public:
    DropoutKernel() : _retainRatio(0.5) {}
    services::Status compute(
        const Tensor &inputTensor,
        Tensor &resultTensor,
        Tensor *maskTensor,
        const dropout::Parameter &parameter);

    services::Status initialize(const dropout::Parameter &parameter);

    services::Status reset();

private:
    static const size_t _nRowsInBlock = 5000;

    algorithmFPType _retainRatio;
    engines::BatchBase *_engine;

    inline Status processBlock(
        const Tensor &inputTensor,
        const size_t nProcessedRows,
        const size_t nRowsInCurrentBlock,
        Tensor &resultTensor,
        Tensor *maskTensor,
        int *rngBuffer,
        const algorithmFPType inverseRetainRatio);

    inline Status processBlockPrediction(
        const Tensor &inputTensor,
        const size_t nProcessedRows,
        const size_t nRowsInCurrentBlock,
        Tensor &resultTensor);
};
} // internal
} // forward

} // dropout
} // layers
} // neural_networks
} // algorithms
} // daal

#endif
