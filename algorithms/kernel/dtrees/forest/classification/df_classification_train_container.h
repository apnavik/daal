/* file: df_classification_train_container.h */
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
//  Implementation of decision forest container.
//--
*/

#ifndef __DF_CLASSIFICATION_TRAIN_CONTAINER_H__
#define __DF_CLASSIFICATION_TRAIN_CONTAINER_H__

#include "kernel.h"
#include "decision_forest_classification_training_types.h"
#include "decision_forest_classification_training_batch.h"
#include "df_classification_train_kernel.h"
#include "df_classification_model_impl.h"
#include "service_algo_utils.h"

namespace daal
{
namespace algorithms
{
namespace decision_forest
{
namespace classification
{
namespace training
{
namespace interface1
{

template <typename algorithmFPType, Method method, CpuType cpu>
BatchContainer<algorithmFPType, method, cpu>::BatchContainer(daal::services::Environment::env *daalEnv)
{
    __DAAL_INITIALIZE_KERNELS(internal::ClassificationTrainBatchKernel, algorithmFPType, method);
}

template <typename algorithmFPType, Method method, CpuType cpu>
BatchContainer<algorithmFPType, method, cpu>::~BatchContainer()
{
    __DAAL_DEINITIALIZE_KERNELS();
}

template <typename algorithmFPType, Method method, CpuType cpu>
services::Status BatchContainer<algorithmFPType, method, cpu>::compute()
{
    classifier::training::Input *input = static_cast<classifier::training::Input *>(_in);
    Result *result = static_cast<Result *>(_res);

    NumericTable *x = input->get(classifier::training::data).get();
    NumericTable *y = input->get(classifier::training::labels).get();

    decision_forest::classification::Model *m = result->get(classifier::training::model).get();

    const decision_forest::classification::training::interface1::Parameter *par =
        static_cast<decision_forest::classification::training::interface1::Parameter*>(_par);
    daal::services::Environment::env &env = *_env;

    __DAAL_CALL_KERNEL(env, internal::ClassificationTrainBatchKernel,
        __DAAL_KERNEL_ARGUMENTS(algorithmFPType, method), compute, daal::services::internal::hostApp(*input), x, y, *m, *result, *par);
}

template <typename algorithmFPType, Method method, CpuType cpu>
services::Status BatchContainer<algorithmFPType, method, cpu>::setupCompute()
{
    Result *result = static_cast<Result *>(_res);
    decision_forest::classification::Model *m = result->get(classifier::training::model).get();
    decision_forest::classification::internal::ModelImpl* pImpl = dynamic_cast<decision_forest::classification::internal::ModelImpl*>(m);
    DAAL_ASSERT(pImpl);
    pImpl->clear();
    return services::Status();
}

}

namespace interface2
{

template <typename algorithmFPType, Method method, CpuType cpu>
BatchContainer<algorithmFPType, method, cpu>::BatchContainer(daal::services::Environment::env *daalEnv)
{
    __DAAL_INITIALIZE_KERNELS(internal::ClassificationTrainBatchKernel, algorithmFPType, method);
}

template <typename algorithmFPType, Method method, CpuType cpu>
BatchContainer<algorithmFPType, method, cpu>::~BatchContainer()
{
    __DAAL_DEINITIALIZE_KERNELS();
}

template <typename algorithmFPType, Method method, CpuType cpu>
services::Status BatchContainer<algorithmFPType, method, cpu>::compute()
{
    classifier::training::Input *input = static_cast<classifier::training::Input *>(_in);
    Result *result = static_cast<Result *>(_res);

    NumericTable *x = input->get(classifier::training::data).get();
    NumericTable *y = input->get(classifier::training::labels).get();

    decision_forest::classification::Model *m = result->get(classifier::training::model).get();

    const decision_forest::classification::training::Parameter *par =
        static_cast<decision_forest::classification::training::Parameter*>(_par);
    daal::services::Environment::env &env = *_env;

    __DAAL_CALL_KERNEL(env, internal::ClassificationTrainBatchKernel,
        __DAAL_KERNEL_ARGUMENTS(algorithmFPType, method), compute, daal::services::internal::hostApp(*input), x, y, *m, *result, *par);
}

template <typename algorithmFPType, Method method, CpuType cpu>
services::Status BatchContainer<algorithmFPType, method, cpu>::setupCompute()
{
    Result *result = static_cast<Result *>(_res);
    decision_forest::classification::Model *m = result->get(classifier::training::model).get();
    decision_forest::classification::internal::ModelImpl* pImpl = dynamic_cast<decision_forest::classification::internal::ModelImpl*>(m);
    DAAL_ASSERT(pImpl);
    pImpl->clear();
    return services::Status();
}

}
}
}
}
}
}

#endif
