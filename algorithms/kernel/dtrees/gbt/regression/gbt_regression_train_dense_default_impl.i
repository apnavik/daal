/* file: gbt_regression_train_dense_default_impl.i */
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
//  Implementation of auxiliary functions for gradient boosted trees regression
//  (defaultDense) method.
//--
*/

#ifndef __GBT_REGRESSION_TRAIN_DENSE_DEFAULT_IMPL_I__
#define __GBT_REGRESSION_TRAIN_DENSE_DEFAULT_IMPL_I__

#include "gbt_regression_train_kernel.h"
#include "gbt_regression_model_impl.h"
#include "gbt_train_dense_default_impl.i"
#include "gbt_train_tree_builder.i"

using namespace daal::algorithms::dtrees::training::internal;
using namespace daal::algorithms::gbt::training::internal;

namespace daal
{
namespace algorithms
{
namespace gbt
{
namespace regression
{
namespace training
{
namespace internal
{

//////////////////////////////////////////////////////////////////////////////////////////
// Squared loss function, L(y,f)=1/2([y-f(x)]^2)
//////////////////////////////////////////////////////////////////////////////////////////
template <typename algorithmFPType, CpuType cpu>
class SquaredLoss : public LossFunction<algorithmFPType, cpu>
{
public:
    virtual void getGradients(size_t n, size_t nRows, const algorithmFPType* y, const algorithmFPType* f,
        const IndexType* sampleInd,
        algorithmFPType* gh) DAAL_C11_OVERRIDE
    {
        if(sampleInd)
        {
            PRAGMA_IVDEP
            PRAGMA_VECTOR_ALWAYS
            for(size_t i = 0; i < n; ++i)
            {
                gh[2 * sampleInd[i]] = f[sampleInd[i]] - y[sampleInd[i]]; //gradient
                gh[2 * sampleInd[i] + 1] = 1; //hessian
            }
        }
        else
        {
            PRAGMA_IVDEP
            PRAGMA_VECTOR_ALWAYS
            for(size_t i = 0; i < n; ++i)
            {
                gh[2 * i] = f[i] - y[i]; //gradient
                gh[2 * i + 1] = 1; //hessian
            }
        }
    }
};

//////////////////////////////////////////////////////////////////////////////////////////
// TrainBatchTask for regression
//////////////////////////////////////////////////////////////////////////////////////////
template <typename algorithmFPType, typename BinIndexType, gbt::regression::training::Method method, CpuType cpu>
class TrainBatchTask : public TrainBatchTaskBaseXBoost<algorithmFPType, BinIndexType, cpu>
{
    typedef TrainBatchTaskBaseXBoost<algorithmFPType, BinIndexType, cpu> super;
public:
    TrainBatchTask(HostAppIface* pHostApp, const NumericTable *x, const NumericTable *y,
        const gbt::training::Parameter& par,
        const dtrees::internal::FeatureTypes& featTypes,
        const dtrees::internal::IndexedFeatures* indexedFeatures,
        engines::internal::BatchBaseImpl& engine, size_t dummy) :
        super(pHostApp, x, y, par, featTypes, indexedFeatures, engine, 1),
        _builder(nullptr)
    {
        _builder = TreeBuilder<algorithmFPType, int, BinIndexType, cpu>::create(*this); // TODO: replace int
    }
    ~TrainBatchTask() { delete _builder; }
    bool done() { return false; }
    virtual services::Status init() DAAL_C11_OVERRIDE
    {
        auto s = super::init();
        if(s)
            s = _builder->init();
        return s;
    }

protected:
    virtual void initLossFunc() DAAL_C11_OVERRIDE
    {
        switch(static_cast<const gbt::regression::training::Parameter&>(this->_par).loss)
        {
        case squared:
            this->_loss = new SquaredLoss<algorithmFPType, cpu>(); break;
        default:
            DAAL_ASSERT(false);
        }
    }

    virtual bool getInitialF(algorithmFPType& val) DAAL_C11_OVERRIDE
    {
        const auto py = this->_dataHelper.y();
        const size_t n = this->_dataHelper.data()->getNumberOfRows();
        const algorithmFPType div = algorithmFPType(1.) / algorithmFPType(n);
        val = algorithmFPType(0);
        for(size_t i = 0; i < n; ++i)
            val += div*py[i];
        return true;
    }

    virtual services::Status buildTrees(gbt::internal::GbtDecisionTree** aTbl,
        HomogenNumericTable<double>** aTblImp, HomogenNumericTable<int>** aTblSmplCnt, GlobalStorages<algorithmFPType, BinIndexType, cpu>& GH_SUMS_BUF) DAAL_C11_OVERRIDE
    {
        this->_nParallelNodes.inc();
        return _builder->run(aTbl[0], aTblImp[0], aTblSmplCnt[0], 0, GH_SUMS_BUF);
    }

protected:
    TreeBuilder<algorithmFPType, int, BinIndexType, cpu>* _builder; // TODO: replace int
};

//////////////////////////////////////////////////////////////////////////////////////////
// RegressionTrainBatchKernel
//////////////////////////////////////////////////////////////////////////////////////////
template <typename algorithmFPType, gbt::regression::training::Method method, CpuType cpu>
services::Status RegressionTrainBatchKernel<algorithmFPType, method, cpu>::compute(
    HostAppIface* pHostApp, const NumericTable *x, const NumericTable *y, gbt::regression::Model& m, Result& res, const Parameter& par,
    engines::internal::BatchBaseImpl& engine)
{
    const size_t nFeaturesPerNode = par.featuresPerNode ? par.featuresPerNode : x->getNumberOfColumns();
    const bool inexactWithHistMethod = !par.memorySavingMode && par.splitMethod == gbt::training::inexact && x->getNumberOfColumns() == nFeaturesPerNode;

    services::Status s;
    dtrees::internal::IndexedFeatures indexedFeatures;
    dtrees::internal::FeatureTypes featTypes;
    DAAL_CHECK_MALLOC(featTypes.init(*x));

    if(!par.memorySavingMode)
    {
        BinParams prm(par.maxBins, par.minBinSize);
        DAAL_CHECK_STATUS(s, (indexedFeatures.init<algorithmFPType, cpu>(*x, &featTypes, par.splitMethod == gbt::training::inexact ? &prm : nullptr)));
    }

    WriteOnlyRows<algorithmFPType, cpu> weightsRows, totalCoverRows, coverRows, totalGainRows, gainRows;

    if (par.resultsToCompute & gbt::training::computeWeight)
    {
        weightsRows.set(res.get(variableImportanceWeight).get(), 0, 1);
    }
    if (par.resultsToCompute & gbt::training::computeTotalCover)
    {
        totalCoverRows.set(res.get(variableImportanceTotalCover).get(), 0, 1);
    }
    if (par.resultsToCompute & gbt::training::computeCover)
    {
        coverRows.set(res.get(variableImportanceCover).get(), 0, 1);
    }
    if (par.resultsToCompute & gbt::training::computeTotalGain)
    {
        totalGainRows.set(res.get(variableImportanceTotalGain).get(), 0, 1);
    }
    if (par.resultsToCompute & gbt::training::computeGain)
    {
        gainRows.set(res.get(variableImportanceGain).get(), 0, 1);
    }

    algorithmFPType* ptrWeight     = weightsRows.get();
    algorithmFPType* ptrTotalCover = totalCoverRows.get();
    algorithmFPType* ptrCover      = coverRows.get();
    algorithmFPType* ptrTotalGain  = totalGainRows.get();
    algorithmFPType* ptrGain       = gainRows.get();

    if(inexactWithHistMethod)
    {
        if (indexedFeatures.maxNumIndices() <= 256)
            return computeImpl<algorithmFPType, cpu, uint8_t, TrainBatchTask<algorithmFPType, uint8_t, method, cpu >, Result>
                (pHostApp, x, y, *static_cast<daal::algorithms::gbt::regression::internal::ModelImpl*>(&m), par, engine, 1, indexedFeatures, featTypes,
                &res, ptrWeight, ptrCover, ptrTotalCover, ptrGain, ptrTotalGain);
        else if (indexedFeatures.maxNumIndices() <= 65536)
            return computeImpl<algorithmFPType, cpu, uint16_t, TrainBatchTask<algorithmFPType, uint16_t, method, cpu >, Result>
                (pHostApp, x, y, *static_cast<daal::algorithms::gbt::regression::internal::ModelImpl*>(&m), par, engine, 1, indexedFeatures, featTypes,
                &res, ptrWeight, ptrCover, ptrTotalCover, ptrGain, ptrTotalGain);
        else
            return computeImpl<algorithmFPType, cpu, uint32_t, TrainBatchTask<algorithmFPType, uint32_t, method, cpu >, Result>
                (pHostApp, x, y, *static_cast<daal::algorithms::gbt::regression::internal::ModelImpl*>(&m), par, engine, 1, indexedFeatures, featTypes,
                &res, ptrWeight, ptrCover, ptrTotalCover, ptrGain, ptrTotalGain);
    }
    else
    {
        return computeImpl<algorithmFPType, cpu, uint32_t, TrainBatchTask<algorithmFPType, uint32_t, method, cpu >, Result>
            (pHostApp, x, y, *static_cast<daal::algorithms::gbt::regression::internal::ModelImpl*>(&m), par, engine, 1, indexedFeatures, featTypes,
            &res, ptrWeight, ptrCover, ptrTotalCover, ptrGain, ptrTotalGain);
    }
}

} /* namespace internal */
} /* namespace training */
} /* namespace regression */
} /* namespace gbt */
} /* namespace algorithms */
} /* namespace daal */

#endif
