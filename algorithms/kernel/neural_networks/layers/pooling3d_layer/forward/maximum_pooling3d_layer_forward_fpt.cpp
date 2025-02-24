/* file: maximum_pooling3d_layer_forward_fpt.cpp */
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
//  Implementation of maximum_pooling3d calculation algorithm and types methods.
//--
*/

#include "maximum_pooling3d_layer_forward_types.h"
#include "maximum_pooling3d_layer_types.h"

namespace daal
{
namespace algorithms
{
namespace neural_networks
{
namespace layers
{
namespace maximum_pooling3d
{
namespace forward
{
namespace interface1
{
/**
 * Allocates memory to store the result of the forward maximum 3D pooling layer
 * \param[in] input Pointer to an object containing the input data
 * \param[in] parameter %Parameter of the forward maximum 3D pooling layer
 * \param[in] method Computation method for the layer
 */
template <typename algorithmFPType>
DAAL_EXPORT services::Status Result::allocate(const daal::algorithms::Input *input, const daal::algorithms::Parameter *parameter, const int method)
{
    services::Status s;
    DAAL_CHECK_STATUS(s, pooling3d::forward::Result::allocate<algorithmFPType>(input, parameter, method));

    const Parameter *algParameter = static_cast<const Parameter *>(parameter);
    if(!algParameter->predictionStage)
    {
        const Input *in = static_cast<const Input *>(input);
        const services::Collection<size_t> &dataDims = in->get(layers::forward::data)->getDimensions();
        services::Collection<size_t> valueDims(dataDims);
        computeValueDimensions(valueDims, algParameter);
        set(auxSelectedIndices, data_management::HomogenTensor<int>::create(valueDims, data_management::Tensor::doAllocate, &s));
        set(auxInputDimensions, createAuxInputDimensions(dataDims));
    }
    return s;
}

template DAAL_EXPORT services::Status Result::allocate<DAAL_FPTYPE>(const daal::algorithms::Input *input, const daal::algorithms::Parameter *parameter, const int method);

}// namespace interface1
}// namespace forward
}// namespace maximum_pooling3d
}// namespace layers
}// namespace neural_networks
}// namespace algorithms
}// namespace daal
