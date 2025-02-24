/* file: layer_descriptor.h */
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
//  Implementation of neural network layer descriptor.
//--
*/

#ifndef __LAYER_DESCRIPTOR_H__
#define __LAYER_DESCRIPTOR_H__

#include "algorithms/neural_networks/layers/layer.h"

namespace daal
{
namespace algorithms
{
namespace neural_networks
{
namespace layers
{
namespace interface1
{
/**
 * @ingroup layers
 * @{
 */
/**
* <a name="DAAL-CLASS-ALGORITHMS__NEURAL_NETWORKS__LAYERS__LAYERDESCRIPTOR"></a>
* \brief Class defining descriptor for layer on both forward and backward stages and its parameters
*/
class LayerDescriptor
{
public:
    DAAL_NEW_DELETE();

    /** Constructs an empty layer descriptor with zero index */
    LayerDescriptor(): _index(0) {}

    /**
     * Constructs a layer descriptor from the provided layer object and an index to be assigned to this object
     * \param[in] index_        Index of the neural network layer
     * \param[in] layer_        Neural network layer
     */
    LayerDescriptor(const size_t index_, const layers::LayerIfacePtr &layer_): _index(index_), _layer(layer_){}

    /**
     * Constructs a layer descriptor from the provided layer object and an index to be assigned to this object,
     * and the collection of indices of the layers following the current layer in the network
     * \param[in] index_        Index of the neural network layer
     * \param[in] layer_        Neural network layer
     * \param[in] nextLayers_   Layers following the current layer in the network
     */
    LayerDescriptor(const size_t index_, const layers::LayerIfacePtr &layer_, const NextLayers &nextLayers_):
        _index(index_), _layer(layer_), _nextLayers(nextLayers_) {};

    /** Constructor */
    LayerDescriptor(const LayerDescriptor& other) : _index(other._index), _layer(other._layer), _nextLayers(other._nextLayers){}

    /**
     * Access to the index of the layer in the network
     * \return Index of the layer in the network
     */
    size_t index() const { return _index; }

    /**
     *  Adds index of a layer to the collection of next layers
     *  \param[in] index Index to add
     */
    services::Status  addNext(size_t index)
    {
        _nextLayers.add(index);
        return services::Status();
    }

    /**
     * Access to the layer in the network
     * \return The layer in the network
     */
    const layers::LayerIfacePtr & layer() const { return _layer; }

    /**
     * Access to the collection of indices of the layers following the current layer in the network
     * \return The collection of indices of the layers following the current layer in the network
     */
    const NextLayers & nextLayers() const { return _nextLayers; }

private:
    layers::LayerIfacePtr _layer; /*!< Layer algorithm */
    NextLayers _nextLayers;       /*!< Layers following the current layer in the network */
    size_t _index;                /*!< Index of the layer in the network */
};
/** @} */
} // interface1
using interface1::LayerDescriptor;

} // namespace layers
} // namespace neural_networks
} // namespace algorithms
} // namespace daal

#endif
