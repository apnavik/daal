/* file: linear_model_train_qr_common_impl.i */
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
//  Implementation of common base classes for normal equations model training.
//--
*/

#include "linear_model_train_qr_kernel.h"
#include "service_lapack.h"

namespace daal
{
namespace algorithms
{
namespace linear_model
{
namespace qr
{
namespace training
{
namespace internal
{
using namespace daal::services;
using namespace daal::data_management;
using namespace daal::internal;
using namespace daal::services::internal;

template <typename algorithmFPType, CpuType cpu>
Status CommonKernel<algorithmFPType, cpu>::computeWorkSize(DAAL_INT nRows, DAAL_INT nCols, DAAL_INT nResponses, DAAL_INT &lwork)
{
    DAAL_INT info;
    algorithmFPType workLocal;

    DAAL_INT lwork1 = -1;
    Lapack<algorithmFPType, cpu>::xxgerqf(&nCols, &nRows, NULL, &nCols, NULL, &workLocal, &lwork1, &info);
    DAAL_CHECK(info == 0, services::ErrorLinearRegressionInternal);

    lwork1 = (DAAL_INT)workLocal;

    char side = 'R';
    char trans = 'T';
    DAAL_INT lwork2 = -1;
    Lapack<algorithmFPType, cpu>::xxormrq(&side, &trans, &nResponses, &nRows, &nCols, NULL,
                                          &nCols, NULL, NULL, &nResponses, &workLocal,
                                          &lwork2, &info);
    DAAL_CHECK(info == 0, services::ErrorLinearRegressionInternal);

    lwork2 = (DAAL_INT)workLocal;
    lwork = daal::services::internal::max<cpu, DAAL_INT>(lwork1, lwork2);

    return Status();
}

template <typename algorithmFPType, CpuType cpu>
Status CommonKernel<algorithmFPType, cpu>::computeQRForBlock(DAAL_INT p, DAAL_INT n,
                                                             const algorithmFPType *x, DAAL_INT ny,
                                                             const algorithmFPType *y, algorithmFPType *r,
                                                             algorithmFPType *qty, algorithmFPType *tau,
                                                             algorithmFPType *work, DAAL_INT lwork)
{
    DAAL_INT info = 0;

    /* Calculate RQ decomposition of X */
    Lapack<algorithmFPType, cpu>::xxgerqf(&p, &n, const_cast<algorithmFPType *>(x), &p, tau, work, &lwork,
                                          &info);
    DAAL_CHECK(info == 0, services::ErrorLinearRegressionInternal);

    /* Copy result into matrix R */
    const DAAL_INT rOffset = (n - p) * p;
    const algorithmFPType *xPtr = x + rOffset;
    for (size_t i = 0; i < p; i++)
    {
      PRAGMA_IVDEP
      PRAGMA_VECTOR_ALWAYS
        for (size_t j = 0; j <= i; j++)
        {
            r[i * p + j] = xPtr[i * p + j];
        }
    }

    /* Calculate Y*Q' */
    char side = 'R';
    char trans = 'T';
    Lapack<algorithmFPType, cpu>::xxormrq(&side, &trans, &ny, &n, &p, const_cast<algorithmFPType *>(x), &p,
                                          tau, const_cast<algorithmFPType *>(y), &ny, work, &lwork, &info);
    DAAL_CHECK(info == 0, services::ErrorLinearRegressionInternal);

    /* Copy result into matrix QTY */
    const DAAL_INT qtySize = ny * p * sizeof(algorithmFPType);
    const DAAL_INT yqtOffset = (n - p) * ny;
    daal_memcpy_s(qty, qtySize, y + yqtOffset, qtySize);

    return Status();
}

template <typename algorithmFPType, CpuType cpu>
Status CommonKernel<algorithmFPType, cpu>::merge(DAAL_INT nBetas, DAAL_INT nResponses,
                                                const algorithmFPType *r1, const algorithmFPType * qty1,
                                                const algorithmFPType *r2, const algorithmFPType * qty2,
                                                algorithmFPType *r12, algorithmFPType * qty12,
                                                algorithmFPType *r, algorithmFPType * qty,
                                                algorithmFPType *tau, algorithmFPType *work, DAAL_INT lwork)
{
    /* Copy R1 and R2 into R12. R12 = (R1, R2) */
    size_t rSize = nBetas * nBetas;
    size_t rSizeInBytes = rSize * sizeof(algorithmFPType);
    daal_memcpy_s(r12        , 2 * rSizeInBytes, r1, rSizeInBytes);
    daal_memcpy_s(r12 + rSize,     rSizeInBytes, r2, rSizeInBytes);
    /* Copy QTY1 and QTY2 into QTY12. QTY12 = (QTY1, QTY2) */
    size_t qtySize = nBetas * nResponses;
    size_t qtySizeInBytes  = qtySize * sizeof(algorithmFPType);
    daal_memcpy_s(qty12          , 2 * qtySizeInBytes, qty1, qtySizeInBytes);
    daal_memcpy_s(qty12 + qtySize,     qtySizeInBytes, qty2, qtySizeInBytes);

    DAAL_INT n = 2 * nBetas;
    return CommonKernel<algorithmFPType, cpu>::computeQRForBlock(nBetas, n, r12, nResponses, qty12, r, qty, tau, work, lwork);
}

}
}
}
}
}
}
