/* file: average_pooling1d_layer_forward_types.h */
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
//  Implementation of forward pooling layer.
//--
*/

#ifndef __AVERAGE_POOLING1D_LAYER_FORWARD_TYPES_H__
#define __AVERAGE_POOLING1D_LAYER_FORWARD_TYPES_H__

#include "algorithms/algorithm.h"
#include "data_management/data/tensor.h"
#include "data_management/data/homogen_tensor.h"
#include "data_management/data/homogen_numeric_table.h"
#include "services/daal_defines.h"
#include "algorithms/neural_networks/layers/pooling1d/average_pooling1d_layer_types.h"
#include "algorithms/neural_networks/layers/pooling1d/pooling1d_layer_forward_types.h"

namespace daal
{
namespace algorithms
{
namespace neural_networks
{
namespace layers
{
namespace average_pooling1d
{
/**
 * @defgroup average_pooling1d_forward Forward One-dimensional Average Pooling Layer
 * \copydoc daal::algorithms::neural_networks::layers::average_pooling1d::forward
 * @ingroup average_pooling1d
 * @{
 */
/**
 * \brief Contains classes for forward average 1D pooling layer
 */
namespace forward
{
/**
 * \brief Contains version 1.0 of Intel(R) Data Analytics Acceleration Library (Intel(R) DAAL) interface.
 */
namespace interface1
{
/**
 * <a name="DAAL-CLASS-ALGORITHMS__NEURAL_NETWORKS__LAYERS__AVERAGE_POOLING1D__FORWARD__INPUT"></a>
 * \brief %Input objects for the forward average 1D pooling layer.
 * See \ref pooling1d::forward::interface1::Input "pooling1d::forward::Input"
 */
class DAAL_EXPORT Input : public pooling1d::forward::Input
{};

/**
 * <a name="DAAL-CLASS-ALGORITHMS__NEURAL_NETWORKS__LAYERS__AVERAGE_POOLING1D__FORWARD__RESULT"></a>
 * \brief Provides methods to access the result obtained with the compute() method
 *        of the forward average 1D pooling layer
 */
class DAAL_EXPORT Result : public pooling1d::forward::Result
{
public:
    DECLARE_SERIALIZABLE_CAST(Result);
    /**
     * Default constructor
     */
    Result();
    virtual ~Result() {}

    using layers::forward::Result::get;
    using layers::forward::Result::set;

    /**
     * Allocates memory to store the result of the forward average 1D pooling layer
     * \param[in] input Pointer to an object containing the input data
     * \param[in] parameter %Parameter of the forward average 1D pooling layer
     * \param[in] method Computation method for the layer
     *
     * \return Status of computations
     */
    template <typename algorithmFPType>
    DAAL_EXPORT services::Status allocate(const daal::algorithms::Input *input, const daal::algorithms::Parameter *parameter, const int method);

    /**
     * Returns the result of the forward average 1D pooling layer
     * \param[in] id    Identifier of the result
     * \return          Result that corresponds to the given identifier
     */
    data_management::NumericTablePtr get(LayerDataId id) const;

    /**
     * Sets the result of the forward average 1D pooling layer
     * \param[in] id      Identifier of the result
     * \param[in] ptr     Result
     */
    void set(LayerDataId id, const data_management::NumericTablePtr &ptr);

    /**
     * Checks the result of the forward average 1D pooling layer
     * \param[in] input     %Input of the layer
     * \param[in] parameter %Parameter of the layer
     * \param[in] method    Computation method of the layer
     *
     * \return Status of computations
     */
    services::Status check(const daal::algorithms::Input *input, const daal::algorithms::Parameter *parameter, int method) const DAAL_C11_OVERRIDE;

protected:
    /** \private */
    template<typename Archive, bool onDeserialize>
    services::Status serialImpl(Archive *arch)
    {
        return daal::algorithms::Result::serialImpl<Archive, onDeserialize>(arch);
    }
};
typedef services::SharedPtr<Result> ResultPtr;

} // namespace interface1
using interface1::Input;
using interface1::Result;
using interface1::ResultPtr;

} // namespace forward
/** @} */
} // namespace average_pooling1d
} // namespace layers
} // namespace neural_networks
} // namespace algorithm
} // namespace daal

#endif
