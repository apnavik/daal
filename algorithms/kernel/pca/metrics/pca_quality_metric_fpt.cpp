/* file: pca_quality_metric_fpt.cpp */
/*******************************************************************************
* Copyright 2014-2018 Intel Corporation.
*
* This software and the related documents are Intel copyrighted  materials,  and
* your use of  them is  governed by the  express license  under which  they were
* provided to you (License).  Unless the License provides otherwise, you may not
* use, modify, copy, publish, distribute,  disclose or transmit this software or
* the related documents without Intel's prior written permission.
*
* This software and the related documents  are provided as  is,  with no express
* or implied  warranties,  other  than those  that are  expressly stated  in the
* License.
*******************************************************************************/

/*
//++
//  Implementation of the class defining the pca explained variance quality metric
//--
*/

#include "pca_quality_metric.h"

namespace daal
{
namespace algorithms
{
namespace pca
{
namespace quality_metric
{
namespace explained_variance
{

template services::Status DAAL_EXPORT Result::allocate<DAAL_FPTYPE>(const daal::algorithms::Input *input, const daal::algorithms::Parameter *par, const int method);

} // namespace explained_variance
} // namespace quality_metric
} // namespace pca
} // namespace algorithms
} // namespace daal