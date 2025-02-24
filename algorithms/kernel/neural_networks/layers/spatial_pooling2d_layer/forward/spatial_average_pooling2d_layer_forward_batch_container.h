/* file: spatial_average_pooling2d_layer_forward_batch_container.h */
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

/*
//++
//  Implementation of forward pooling layer container.
//--
*/

#ifndef __SPATIAL_PYRAMID_AVERAGE_POOLING2D_LAYER_FORWARD_BATCH_CONTAINER_H__
#define __SPATIAL_PYRAMID_AVERAGE_POOLING2D_LAYER_FORWARD_BATCH_CONTAINER_H__

#include "neural_networks/layers/spatial_pooling2d/spatial_average_pooling2d_layer.h"
#include "spatial_pooling2d_layer_forward_kernel.h"

namespace daal
{
namespace algorithms
{
namespace neural_networks
{
namespace layers
{
namespace spatial_average_pooling2d
{
namespace forward
{
namespace interface1
{
template<typename algorithmFPType, CpuType cpu>
BatchContainer<algorithmFPType, defaultDense, cpu>::BatchContainer(daal::services::Environment::env *daalEnv)
{
    __DAAL_INITIALIZE_KERNELS(spatial_pooling2d::forward::internal::PoolingKernel, algorithmFPType, spatial_pooling2d::internal::average);
}

template<typename algorithmFPType, CpuType cpu>
BatchContainer<algorithmFPType, defaultDense, cpu>::~BatchContainer()
{
    __DAAL_DEINITIALIZE_KERNELS();
}

template<typename algorithmFPType, CpuType cpu>
services::Status BatchContainer<algorithmFPType, defaultDense, cpu>::compute()
{
    spatial_average_pooling2d::forward::Input *input = static_cast<spatial_average_pooling2d::forward::Input *>(_in);
    spatial_average_pooling2d::forward::Result *result = static_cast<spatial_average_pooling2d::forward::Result *>(_res);
    spatial_average_pooling2d::Parameter *parameter = static_cast<spatial_average_pooling2d::Parameter *>(_par);

    data_management::Tensor *dataTensor = input->get(layers::forward::data).get();
    data_management::Tensor *valueTensor = result->get(layers::forward::value).get();

    daal::services::Environment::env &env = *_env;

    __DAAL_CALL_KERNEL(env, spatial_pooling2d::forward::internal::PoolingKernel, __DAAL_KERNEL_ARGUMENTS(algorithmFPType, spatial_pooling2d::internal::maximum),   \
                       compute, *dataTensor, *valueTensor, NULL, *parameter);
}
} // namespace interface1
} // namespace forward

} // namespace spatial_average_pooling2d
} // namespace layers
} // namespace neural_networks
} // namespace algorithms
} // namespace daal

#endif
