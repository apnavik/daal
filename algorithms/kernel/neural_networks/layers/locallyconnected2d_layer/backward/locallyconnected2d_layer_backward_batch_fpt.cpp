/* file: locallyconnected2d_layer_backward_batch_fpt.cpp */
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
//  Implementation of locally connected calculation algorithm and types methods.
//--
*/

#include "locallyconnected2d_layer_backward_types.h"
#include "locallyconnected2d_layer_types.h"

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
namespace locallyconnected2d
{
namespace backward
{
namespace interface1
{
/**
 * Allocates memory to store the result of backward 2D locally connected layer
 * \param[in] input     Object containing the input data
 * \param[in] parameter %Parameter of backward 2D locally connected layer
 * \param[in] method    Computation method
 */
template <typename algorithmFPType>
services::Status DAAL_EXPORT Result::allocate(const daal::algorithms::Input *input, const daal::algorithms::Parameter *parameter, const int method)
{
    using daal::data_management::Tensor;
    using daal::data_management::HomogenTensor;

    const Input *algInput = static_cast<const Input *>(input);
    const Parameter *param =  static_cast<const Parameter * >(parameter);

    TensorPtr auxDataTensor = algInput->get(auxData);
    TensorPtr auxWTensor    = algInput->get(auxWeights);

    services::Collection<size_t> bDims;
    getBiasesDims(algInput, param, bDims);

    if(auxDataTensor == 0 || auxWTensor == 0) return services::Status(services::ErrorNullTensor);

    services::Status s;
    if (param->propagateGradient && !get(layers::backward::gradient))
    {
        set(layers::backward::gradient, HomogenTensor<algorithmFPType>::create(auxDataTensor->getDimensions(), Tensor::doAllocate, &s));
    }
    if (!get(layers::backward::weightDerivatives))
    {
        set(layers::backward::weightDerivatives, HomogenTensor<algorithmFPType>::create(auxWTensor->getDimensions(), Tensor::doAllocate, &s));
    }
    if (!get(layers::backward::biasDerivatives))
    {
        set(layers::backward::biasDerivatives, HomogenTensor<algorithmFPType>::create(bDims, Tensor::doAllocate, &s));
    }
    return s;
}

template DAAL_EXPORT services::Status Result::allocate<DAAL_FPTYPE>(const daal::algorithms::Input *input, const daal::algorithms::Parameter *parameter, const int method);

}// namespace interface1
}// namespace backward
}// namespace locallyconnected2d
}// namespace layers
}// namespace neural_networks
}// namespace algorithms
}// namespace daal
