/* file: fullyconnected_layer_forward_kernel.h */
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
//  Declaration of template function that calculate fullyconnecteds.
//--


#ifndef __FULLYCONNECTED_LAYER_FORWARD_KERNEL_H__
#define __FULLYCONNECTED_LAYER_FORWARD_KERNEL_H__

#include "neural_networks/layers/fullyconnected/fullyconnected_layer.h"
#include "neural_networks/layers/fullyconnected/fullyconnected_layer_types.h"
#include "kernel.h"
#include "service_math.h"
#include "numeric_table.h"
#include "service_error_handling.h"
#include "service_tensor.h"

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
namespace fullyconnected
{
namespace forward
{
namespace internal
{
/**
 *  \brief Kernel for fullyconnected calculation
 */
template<typename algorithmFPType, Method method, CpuType cpu>
class FullyconnectedKernel : public Kernel
{
public:
    services::Status compute( const Tensor &inputTensor, const Tensor &wTensor, const Tensor &bTensor, Tensor &resultTensor, const fullyconnected::Parameter &parameter );
};
} // internal
} // forward

} // fullyconnected
} // layers
} // neural_networks
} // algorithms
} // daal

#endif
