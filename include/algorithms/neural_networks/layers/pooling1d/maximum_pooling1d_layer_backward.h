/* file: maximum_pooling1d_layer_backward.h */
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
//  Implementation of the interface for the backward maximum one-dimensional (1D) pooling layer
//  in the batch processing mode
//--
*/

#ifndef __MAXIMUM_POOLING1D_LAYER_BACKWARD_H__
#define __MAXIMUM_POOLING1D_LAYER_BACKWARD_H__

#include "algorithms/algorithm.h"
#include "data_management/data/tensor.h"
#include "services/daal_defines.h"
#include "algorithms/neural_networks/layers/layer.h"
#include "algorithms/neural_networks/layers/pooling1d/maximum_pooling1d_layer_types.h"
#include "algorithms/neural_networks/layers/pooling1d/maximum_pooling1d_layer_backward_types.h"

namespace daal
{
namespace algorithms
{
namespace neural_networks
{
namespace layers
{
namespace maximum_pooling1d
{
namespace backward
{
/**
 * \brief Contains version 1.0 of the Intel(R) Data Analytics Acceleration Library (Intel(R) DAAL) interface
 */
namespace interface1
{
/**
 * @defgroup maximum_pooling1d_backward_batch Batch
 * @ingroup maximum_pooling1d_backward
 * @{
 */
/**
 * <a name="DAAL-CLASS-ALGORITHMS__NEURAL_NETWORKS__LAYERS__MAXIMUM_POOLING1D__BACKWARD__BATCHCONTAINER"></a>
 * \brief Provides methods to run implementations of the backward maximum 1D pooling layer.
 *        This class is associated with the \ref backward::interface1::Batch "backward::Batch" class
 *        and supports the method of backward maximum 1D pooling layer computation in the batch processing mode
 *
 * \tparam algorithmFPType  Data type to use in intermediate computations of backward maximum 1D pooling layer, double or float
 * \tparam method           Computation method of the layer, maximum_pooling1d::Method
 * \tparam cpu              Version of the cpu-specific implementation of the layer, \ref daal::CpuType
 */
template<typename algorithmFPType, Method method, CpuType cpu>
class BatchContainer : public AnalysisContainerIface<batch>
{
public:
    /**
     * Constructs a container for the backward maximum 1D pooling layer with a specified environment
     * in the batch processing mode
     * \param[in] daalEnv   Environment object
     */
    BatchContainer(daal::services::Environment::env *daalEnv);
    /** Default destructor */
    ~BatchContainer();
    /**
     * Computes the result of the backward maximum 1D pooling layer in the batch processing mode
     *
     * \return Status of computations
     */
    services::Status compute() DAAL_C11_OVERRIDE;
};

/**
 * <a name="DAAL-CLASS-ALGORITHMS__NEURAL_NETWORKS__LAYERS__MAXIMUM_POOLING1D__BACKWARD__BATCH"></a>
 * \brief Provides methods for the backward maximum 1D pooling layer in the batch processing mode
 * <!-- \n<a href="DAAL-REF-MAXIMUMPOOLING1DBACKWARD-ALGORITHM">Backward maximum 1D pooling layer description and usage models</a> -->
 *
 * \tparam algorithmFPType  Data type to use in intermediate computations for the backward  maximum 1D pooling layer, double or float
 * \tparam method           Backward maximum 1D pooling layer method, maximum_pooling1d::Method
 *
 * \par Enumerations
 *      - \ref Method                      Computation methods for the backward maximum 1D pooling layer
 *      - \ref backward::InputId           Identifiers of input objects for the backward maximum 1D pooling layer
 *      - \ref LayerDataId                 Identifiers of collection in input objects for the backward maximum 1D pooling layer
 *      - \ref backward::InputLayerDataId  Identifiers of extra results computed by the forward maximum 1D pooling layer
 *      - \ref backward::ResultId          Identifiers of result objects for the backward maximum 1D pooling layer
 *
 * \par References
 *      - \ref forward::interface1::Batch "forward::Batch" class
 */
template<typename algorithmFPType = DAAL_ALGORITHM_FP_TYPE, Method method = defaultDense>
class Batch : public layers::backward::LayerIfaceImpl
{
public:
    typedef layers::backward::LayerIfaceImpl super;

    typedef algorithms::neural_networks::layers::maximum_pooling1d::backward::Input     InputType;
    typedef algorithms::neural_networks::layers::maximum_pooling1d::Parameter           ParameterType;
    typedef algorithms::neural_networks::layers::maximum_pooling1d::backward::Result    ResultType;

    ParameterType &parameter; /*!< Backward maximum 1D pooling layer \ref interface1::Parameter "parameters" */
    InputType input;          /*!< Backward maximum 1D pooling layer input */

    /**
     * Constructs backward maximum 1D pooling layer with the provided parameters
     * \param[in] nDimensions Number of dimensions in input data tensor
     */
    Batch(size_t nDimensions) : _defaultParameter(nDimensions-1), parameter(_defaultParameter)
    {
        initialize();
    }

    /**
     * Constructs a backward maximum 1D pooling layer in the batch processing mode
     * and initializes its parameter with the provided parameter
     * \param[in] parameter Parameter to initialize the parameter of the layer
     */
    Batch(ParameterType& parameter) : parameter(parameter), _defaultParameter(parameter)
    {
        initialize();
    }

    /**
     * Constructs backward maximum 1D pooling layer by copying input objects
     * and parameters of another backward maximum 1D pooling layer in the batch processing mode
     * \param[in] other Algorithm to use as the source to initialize the input objects
     *                  and parameters of the layer
     */
    Batch(const Batch<algorithmFPType, method> &other) : super(other),
        _defaultParameter(other.parameter), parameter(_defaultParameter), input(other.input)
    {
        initialize();
    }

    /**
     * Returns the method of the layer
     * \return Method of the layer
     */
    virtual int getMethod() const DAAL_C11_OVERRIDE { return(int) method; }

    /**
     * Returns the structure that contains the input objects of backward maximum 1D pooling layer
     * \return Structure that contains the input objects of backward maximum 1D pooling layer
     */
    virtual InputType *getLayerInput() DAAL_C11_OVERRIDE { return &input; }

    /**
     * Returns the structure that contains the parameters of the backward maximum 1D pooling layer
     * \return Structure that contains the parameters of the backward maximum 1D pooling layer
     */
    virtual ParameterType *getLayerParameter() DAAL_C11_OVERRIDE { return &parameter; };

    /**
     * Returns the structure that contains result of the backward maximum 1D pooling layer
     * \return Structure that contains result of the backward maximum 1D pooling layer
     */
    layers::backward::ResultPtr getLayerResult() DAAL_C11_OVERRIDE
    {
        return _result;
    }

    /**
     * Returns the structure that contains the result of the backward maximum 1D pooling layer
     * \return Structure that contains the result of the backward maximum 1D pooling layer
     */
    ResultPtr getResult()
    {
        return _result;
    }

    /**
     * Registers user-allocated memory to store the result of the backward maximum 1D pooling layer
     * \param[in] result Structure to store the result of the backward maximum 1D pooling layer
     *
     * \return Status of computations
     */
    services::Status setResult(const ResultPtr& result)
    {
        DAAL_CHECK(result, services::ErrorNullResult)
        _result = result;
        _res = _result.get();
        return services::Status();
    }

    /**
     * Returns a pointer to a newly allocated backward maximum 1D pooling layer
     * with a copy of the input objects and parameters for this backward maximum 1D pooling layer
     * in the batch processing mode
     * \return Pointer to the newly allocated layer
     */
    services::SharedPtr<Batch<algorithmFPType, method> > clone() const
    {
        return services::SharedPtr<Batch<algorithmFPType, method> >(cloneImpl());
    }

    /**
     * Allocates memory to store the result of the backward maximum 1D pooling layer
     *
     * \return Status of computations
     */
    virtual services::Status allocateResult() DAAL_C11_OVERRIDE
    {
        services::Status s = this->_result->template allocate<algorithmFPType>(&(this->input), &parameter, (int) method);
        this->_res = this->_result.get();
        return s;
    }

protected:
    virtual Batch<algorithmFPType, method> *cloneImpl() const DAAL_C11_OVERRIDE
    {
        return new Batch<algorithmFPType, method>(*this);
    }

    void initialize()
    {
        Analysis<batch>::_ac = new __DAAL_ALGORITHM_CONTAINER(batch, BatchContainer, algorithmFPType, method)(&_env);
        _in = &input;
        _par = &parameter;
        _result.reset(new ResultType());
    }

private:
    ResultPtr _result;
    ParameterType _defaultParameter;
};
/** @} */
} // namespace interface1
using interface1::BatchContainer;
using interface1::Batch;
} // namespace backward
} // namespace maximum_pooling1d
} // namespace layers
} // namespace neural_networks
} // namespace algorithms
} // namespace daal
#endif
