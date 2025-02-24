/* file: transposed_conv2d_layer_forward_batch_fpt.cpp */
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
//  Implementation of transposed convolution2d calculation algorithm and types methods.
//--
*/

#include "transposed_conv2d_layer_forward_types.h"
#include "transposed_conv2d_layer_types.h"

namespace daal
{
namespace algorithms
{
namespace neural_networks
{
namespace layers
{
namespace transposed_conv2d
{
namespace forward
{
namespace interface1
{

/**
* Allocates memory to store the result of forward  2D transposed convolution layer
 * \param[in] parameter %Parameter of forward 2D transposed convolution layer
 * \param[in] method    Computation method for the layer
*
 * \return Status of computations
 */
template <typename algorithmFPType>
DAAL_EXPORT services::Status Input::allocate(const daal::algorithms::Parameter *parameter, const int method)
{
    using daal::services::SharedPtr;
    using daal::data_management::Tensor;
    using daal::data_management::HomogenTensor;

    const Parameter *param =  static_cast<const Parameter * >(parameter);
    services::Status s;
    if( !get(layers::forward::weights) )
    {
        SharedPtr<Tensor> tensor = HomogenTensor<algorithmFPType>::create(getWeightsSizes(param), Tensor::doAllocate, &s);
        set(layers::forward::weights, tensor);
    }

    if( !get(layers::forward::biases) )
    {
        SharedPtr<Tensor> tensor = HomogenTensor<algorithmFPType>::create(getBiasesSizes(param), Tensor::doAllocate, &s);
        set(layers::forward::biases, tensor);
    }
    return s;
}

/**
 * Allocates memory to store the result of forward  2D transposed convolution layer
 * \param[in] input     %Input object for the algorithm
 * \param[in] parameter %Parameter of forward 2D transposed convolution layer
 * \param[in] method    Computation method for the layer
 *
 * \return Status of computations
 */
template <typename algorithmFPType>
DAAL_EXPORT services::Status Result::allocate(const daal::algorithms::Input *input, const daal::algorithms::Parameter *parameter, const int method)
{
    using namespace data_management;
    const Input *in = static_cast<const Input * >(input);

    const services::Collection<size_t> &inDims = in->get(layers::forward::data)->getDimensions();
    services::Status s;
    if (!get(layers::forward::value))
    {
        set(layers::forward::value, HomogenTensor<algorithmFPType>::create(getValueSize(inDims, parameter, method), Tensor::doAllocate, &s));
    }

    const layers::Parameter *par = static_cast<const layers::Parameter * >(parameter);
    if(!par->predictionStage)
    {
        set(layers::forward::resultForBackward, services::SharedPtr<LayerData>(new LayerData()));
        setResultForBackward(input);
    }
    return s;
}


template DAAL_EXPORT services::Status Input::allocate<DAAL_FPTYPE>(const daal::algorithms::Parameter *parameter, const int method);
template DAAL_EXPORT services::Status Result::allocate<DAAL_FPTYPE>(const daal::algorithms::Input *input, const daal::algorithms::Parameter *parameter, const int method);

}// namespace interface1
}// namespace forward
}// namespace transposed_conv2d
}// namespace layers
}// namespace neural_networks
}// namespace algorithms
}// namespace daal
