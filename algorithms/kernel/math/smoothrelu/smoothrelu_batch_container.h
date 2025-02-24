/* file: smoothrelu_batch_container.h */
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
//  Implementation of smoothrelu calculation algorithm container.
//--
*/

#ifndef __SMOOTHRELU_BATCH_CONTAINER_H__
#define __SMOOTHRELU_BATCH_CONTAINER_H__

#include "math/smoothrelu.h"
#include "smoothrelu_kernel.h"

namespace daal
{
namespace algorithms
{
namespace math
{
namespace smoothrelu
{
namespace interface1
{
template<typename algorithmFPType, Method method, CpuType cpu>
BatchContainer<algorithmFPType, method, cpu>::BatchContainer(daal::services::Environment::env *daalEnv)
{
    __DAAL_INITIALIZE_KERNELS(internal::SmoothReLUKernel, algorithmFPType, method);
}

template<typename algorithmFPType, Method method, CpuType cpu>
BatchContainer<algorithmFPType, method, cpu>::~BatchContainer()
{
    __DAAL_DEINITIALIZE_KERNELS();
}

template<typename algorithmFPType, Method method, CpuType cpu>
services::Status BatchContainer<algorithmFPType, method, cpu>::compute()
{
    Input *input = static_cast<Input *>(_in);
    Result *result = static_cast<Result *>(_res);

    daal::services::Environment::env &env = *_env;

    __DAAL_CALL_KERNEL(env, internal::SmoothReLUKernel, __DAAL_KERNEL_ARGUMENTS(algorithmFPType, method), compute, input->get(data).get(), result->get(value).get());
}

} // namespace interface1
} // namespace smoothrelu
} // namespace math
} // namespace algorithms
} // namespace daal

#endif
