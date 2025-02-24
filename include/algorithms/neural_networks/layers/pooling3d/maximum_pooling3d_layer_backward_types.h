/* file: maximum_pooling3d_layer_backward_types.h */
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
//  Implementation of backward maximum 3D pooling layer.
//--
*/

#ifndef __MAXIMUM_POOLING3D_LAYER_BACKWARD_TYPES_H__
#define __MAXIMUM_POOLING3D_LAYER_BACKWARD_TYPES_H__

#include "algorithms/algorithm.h"
#include "data_management/data/tensor.h"
#include "data_management/data/homogen_tensor.h"
#include "services/daal_defines.h"
#include "algorithms/neural_networks/layers/pooling3d/pooling3d_layer_backward_types.h"
#include "algorithms/neural_networks/layers/pooling3d/maximum_pooling3d_layer_types.h"

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
/**
 * @defgroup maximum_pooling3d_backward Backward Three-dimensional Max Pooling Layer
 * \copydoc daal::algorithms::neural_networks::layers::maximum_pooling3d::backward
 * @ingroup maximum_pooling3d
 * @{
 */
/**
 * \brief Contains classes for backward maximum 3D pooling layer
 */
namespace backward
{

/**
 * \brief Contains version 1.0 of Intel(R) Data Analytics Acceleration Library (Intel(R) DAAL) interface.
 */
namespace interface1
{

/**
 * <a name="DAAL-CLASS-ALGORITHMS__NEURAL_NETWORKS__LAYERS__MAXIMUM_POOLING3D__BACKWARD__INPUT"></a>
 * \brief %Input objects for the backward maximum 3D pooling layer
 */
class DAAL_EXPORT Input : public pooling3d::backward::Input
{
public:
    typedef pooling3d::backward::Input super;
    /**
     * Default constructor
     */
    Input();

    /** Copy constructor */
    Input(const Input& other);

    virtual ~Input() {}

    using layers::backward::Input::get;
    using layers::backward::Input::set;

    /**
     * Returns an input object for backward maximum 3D pooling layer
     * \param[in] id    Identifier of the input object
     * \return          %Input object that corresponds to the given identifier
     */
    data_management::TensorPtr get(LayerDataId id) const;

    /**
     * Returns an input object for backward maximum 3D pooling layer
     * \param[in] id    Identifier of the input object
     * \return          %Input object that corresponds to the given identifier
     */
    data_management::NumericTablePtr get(LayerDataNumericTableId id) const;

    /**
     * Sets an input object for the backward maximum 3D pooling layer
     * \param[in] id  Identifier of the input object
     * \param[in] ptr Pointer to the object
     */
    void set(LayerDataId id, const data_management::TensorPtr &ptr);

    /**
     * Sets an input object for the backward maximum 3D pooling layer
     * \param[in] id  Identifier of the input object
     * \param[in] ptr Pointer to the object
     */
    void set(LayerDataNumericTableId id, const data_management::NumericTablePtr &ptr);

    /**
     * Checks an input object for the backward maximum 3D pooling layer
     * \param[in] parameter Algorithm parameter
     * \param[in] method    Computation method
     *
     * \return Status of computations
     */
    services::Status check(const daal::algorithms::Parameter *parameter, int method) const DAAL_C11_OVERRIDE;

protected:
    virtual data_management::NumericTablePtr getAuxInputDimensions() const DAAL_C11_OVERRIDE;
};

/**
 * <a name="DAAL-CLASS-ALGORITHMS__NEURAL_NETWORKS__LAYERS__MAXIMUM_POOLING3D__BACKWARD__RESULT"></a>
 * \brief Provides methods to access the result obtained with the compute() method
 *        of the backward maximum 3D pooling layer
 */
class DAAL_EXPORT Result : public pooling3d::backward::Result
{
public:
    DECLARE_SERIALIZABLE_CAST(Result);
    /**
     * Default constructor
     */
    Result();
    virtual ~Result() {}

    using layers::backward::Result::get;
    using layers::backward::Result::set;

    /**
     * Allocates memory to store the result of the backward maximum 3D pooling layer
     * \param[in] input Pointer to an object containing the input data
     * \param[in] parameter %Parameter of the backward maximum 3D pooling layer
     * \param[in] method Computation method for the layer
     *
     * \return Status of computations
     */
    template <typename algorithmFPType>
    DAAL_EXPORT services::Status allocate(const daal::algorithms::Input *input, const daal::algorithms::Parameter *parameter, const int method);

    /**
     * Checks the result of the backward maximum 3D pooling layer
     * \param[in] input     %Input object for the layer
     * \param[in] parameter %Parameter of the layer
     * \param[in] method    Computation method
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
} // namespace backward
/** @} */
} // namespace maximum_pooling3d
} // namespace layers
} // namespace neural_networks
} // namespace algorithm
} // namespace daal

#endif
