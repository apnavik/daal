/* file: stochastic_pooling2d_layer_backward_dense_default_batch_fpt_dispatcher.cpp */
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
//  Implementation of backward pooling layer container.
//--


#include "kernel.h"
#include "neural_networks/layers/pooling2d/stochastic_pooling2d_layer.h"

namespace daal
{
namespace algorithms
{
__DAAL_INSTANTIATE_DISPATCH_CONTAINER(neural_networks::layers::stochastic_pooling2d::backward::interface1::BatchContainer, batch, DAAL_FPTYPE,
                                      neural_networks::layers::stochastic_pooling2d::defaultDense)
}
} // namespace daal
