/* file: uniform_initializer_batch_container.h */
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
//  Implementation of uniform calculation algorithm container.
//--
*/

#ifndef __UNIFORM_INITIALIZER_BATCH_CONTAINER_H__
#define __UNIFORM_INITIALIZER_BATCH_CONTAINER_H__

#include "neural_networks/initializers/uniform/uniform_initializer.h"
#include "uniform_initializer_kernel.h"

namespace daal
{
namespace algorithms
{
namespace neural_networks
{
namespace initializers
{
namespace uniform
{
namespace interface1
{
template<typename algorithmFPType, Method method, CpuType cpu>
BatchContainer<algorithmFPType, method, cpu>::BatchContainer(daal::services::Environment::env *daalEnv)
{
    __DAAL_INITIALIZE_KERNELS(internal::UniformKernel, algorithmFPType, method);
}

template<typename algorithmFPType, Method method, CpuType cpu>
BatchContainer<algorithmFPType, method, cpu>::~BatchContainer()
{
    __DAAL_DEINITIALIZE_KERNELS();
}

template<typename algorithmFPType, Method method, CpuType cpu>
services::Status BatchContainer<algorithmFPType, method, cpu>::compute()
{
    initializers::Result *result  = static_cast<initializers::Result *>(_res);
    uniform::Parameter *parameter = static_cast<uniform::Parameter *>(_par);

    daal::services::Environment::env &env = *_env;
    __DAAL_CALL_KERNEL(env, internal::UniformKernel, __DAAL_KERNEL_ARGUMENTS(algorithmFPType, method), compute,
        internal::UniformInitializerTaskDescriptor(result, parameter)
    );
}
} // namespace interface1
} // namespace uniform
} // namespace initializers
} // namespace neural_networks
} // namespace algorithms
} // namespace daal

#endif
