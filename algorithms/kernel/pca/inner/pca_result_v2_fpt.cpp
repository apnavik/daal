/* file: pca_result_v2_fpt.cpp */
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
//  Implementation of PCA algorithm interface.
//--
*/
#include "pca/inner/pca_types_v2.h"
#include "pca/inner/pca_result_v2.h"

namespace daal
{
namespace algorithms
{
namespace pca
{
namespace interface2
{

/**
 * Allocates memory for storing partial results of the PCA algorithm
 * \param[in] input Pointer to an object containing input data
 * \param[in] parameter Algorithm parameter
 * \param[in] method Computation method
 */
template<typename algorithmFPType>
DAAL_EXPORT services::Status Result::allocate(const daal::algorithms::Input *input, daal::algorithms::Parameter *parameter, const Method method)
{
    size_t nComponents = 0;
    DAAL_UINT64 resultsToCompute = eigenvalue;

    const auto* par = dynamic_cast<const interface2::BaseBatchParameter*>(parameter);
    if (par != NULL)
    {
        nComponents = par->nComponents;
        resultsToCompute = par->resultsToCompute;
    }

    auto impl = ResultImpl::cast(getStorage(*this));
    DAAL_CHECK(impl, services::ErrorNullPtr);

    return impl->allocate<algorithmFPType>(input, nComponents, resultsToCompute);
}

/**
 * Allocates memory for storing partial results of the PCA algorithm
 * \param[in] partialResult Pointer to an object containing input data
 * \param[in] parameter Parameter of the algorithm
 * \param[in] method        Computation method
 */
template<typename algorithmFPType>
DAAL_EXPORT services::Status Result::allocate(const daal::algorithms::PartialResult *partialResult, daal::algorithms::Parameter *parameter, const Method method)
{
    size_t nComponents = 0;
    DAAL_UINT64 resultsToCompute = eigenvalue;

    auto impl = ResultImpl::cast(getStorage(*this));
    DAAL_CHECK(impl, services::ErrorNullPtr);

    return impl->allocate<algorithmFPType>(partialResult, nComponents, resultsToCompute);
}

template DAAL_EXPORT services::Status Result::allocate<DAAL_FPTYPE>(const daal::algorithms::Input *input, daal::algorithms::Parameter *parameter, const Method method);
template DAAL_EXPORT services::Status Result::allocate<DAAL_FPTYPE>(const daal::algorithms::PartialResult *partialResult, daal::algorithms::Parameter *parameter, const Method method);

}// interface2
}// namespace pca
}// namespace algorithms
}// namespace daal
