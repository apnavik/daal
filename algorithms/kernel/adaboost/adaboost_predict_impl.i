/* file: adaboost_predict_impl.i */
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
//  Implementation of Fast method for Ada Boost prediction algorithm.
//--
*/

#ifndef __ADABOOST_PREDICT_IMPL_I__
#define __ADABOOST_PREDICT_IMPL_I__

#include "service_numeric_table.h"
#include "collection.h"
#include "service_math.h"
#include "service_data_utils.h"

namespace daal
{
namespace algorithms
{
namespace adaboost
{
namespace prediction
{
namespace internal
{
using namespace daal::internal;
template <Method method, typename algorithmFPType, CpuType cpu>
services::Status AdaBoostPredictKernelNew<method, algorithmFPType, cpu>::computeImpl(const NumericTablePtr &xTable,
        const Model *m, size_t nWeakLearners, const algorithmFPType *alpha, algorithmFPType *r, const Parameter *par)
{
    const size_t nVectors  = xTable->getNumberOfRows();
    Model *boostModel = const_cast<Model *>(m);
    Parameter *parameter = const_cast<Parameter *>(par);

    services::Status s;
    services::SharedPtr<daal::internal::HomogenNumericTableCPU<algorithmFPType, cpu> > rWeakTable =
        daal::internal::HomogenNumericTableCPU<algorithmFPType, cpu>::create(1, nVectors, &s);
    DAAL_CHECK_STATUS_VAR(s);
    const algorithmFPType *rWeak = rWeakTable->getArray();

    services::SharedPtr<classifier::prediction::Batch> learnerPredict = parameter->weakLearnerPrediction->clone();
    classifier::prediction::Input *learnerInput = learnerPredict->getInput();
    DAAL_CHECK(learnerInput, services::ErrorNullInput);
    learnerInput->set(classifier::prediction::data, xTable);

    classifier::prediction::ResultPtr predictionRes(new classifier::prediction::Result());
    predictionRes->set(classifier::prediction::prediction, rWeakTable);
    DAAL_CHECK_STATUS(s, learnerPredict->setResult(predictionRes));

    const algorithmFPType zero = (algorithmFPType)0.0;

    /* Initialize array of prediction results */
    for (size_t j = 0; j < nVectors; j++)
    {
        r[j] = zero;
    }

    const algorithmFPType one = (algorithmFPType)1.0;
    for(size_t i = 0; i < nWeakLearners; i++)
    {
        /* Get  weak learner's classification results */
        classifier::ModelPtr learnerModel = boostModel->getWeakLearnerModel(i);

        learnerInput->set(classifier::prediction::model, learnerModel);
        DAAL_CHECK_STATUS(s, learnerPredict->computeNoThrow());

        /* Update boosting classification results */
        for (size_t j = 0; j < nVectors; j++)
        {
            algorithmFPType p = ((rWeak[j] > zero) ? one : -one);
            r[j] += p * alpha[i];
        }
    }

    for(size_t j = 0; j < nVectors; j++)
    {
        r[j] = ((r[j] >= zero) ? one : -one);
    }

    return s;
}

template <Method method, typename algorithmFPType, CpuType cpu>
services::Status AdaBoostPredictKernelNew<method, algorithmFPType, cpu>::computeSammeProbability(
    const algorithmFPType *p, const size_t nVectors, const size_t nClasses, algorithmFPType *h)
{
    algorithmFPType *pLog = h;
    TArray<algorithmFPType, cpu> pSumLogArray(nVectors);
    DAAL_CHECK(pSumLogArray.get(), services::ErrorMemoryAllocationFailed);
    algorithmFPType *pSumLog = pSumLogArray.get();
    for(size_t i = 0; i < nVectors; i++)
    {
        pSumLog[i] = 0;
    }

    algorithmFPType eps = services::internal::EpsilonVal<algorithmFPType>::get();
    for(size_t i = 0; i < nVectors * nClasses; i++)
    {
        if (p[i] < eps) {pLog[i] = eps;}
        else {pLog[i] = p[i];}
    }

    Math<algorithmFPType, cpu>::vLog(nVectors * nClasses, p, pLog);

    for(size_t i = 0; i < nVectors; i++)
    {
        for(size_t j = 0; j < nClasses; j++)
        {
            pSumLog[i] += pLog[i * nClasses + j];
        }
        pSumLog[i] /= nClasses;
        for(size_t j = 0; j < nClasses; j++)
        {
            h[i * nClasses + j] = (nClasses - 1.0) * (pLog[i * nClasses + j] - pSumLog[i]);
        }
    }
    return services::Status();
}


template <Method method, typename algorithmFPType, CpuType cpu>
services::Status AdaBoostPredictKernelNew<method, algorithmFPType, cpu>::computeCommon(const NumericTablePtr &xTable,
        const Model *m, size_t nWeakLearners, const algorithmFPType *alpha, algorithmFPType *r, const Parameter *par)
{
    const size_t nClasses = par->nClasses;
    typedef daal::internal::HomogenNumericTableCPU<algorithmFPType, cpu> HomoNTCPU;
    const size_t nVectors  = xTable->getNumberOfRows();
    Model *boostModel = const_cast<Model *>(m);
    Parameter *parameter = const_cast<Parameter *>(par);

    daal::services::Collection<services::SharedPtr<HomoNTCPU> > weakPredictions;

    services::Status s;

    services::SharedPtr<classifier::prediction::Batch> learnerPredict = parameter->weakLearnerPrediction->clone();
    classifier::prediction::Input *learnerInput = learnerPredict->getInput();
    DAAL_CHECK(learnerInput, services::ErrorNullInput);
    learnerInput->set(classifier::prediction::data, xTable);

    classifier::prediction::ResultPtr predictionRes(new classifier::prediction::Result());
    DAAL_CHECK_STATUS(s, learnerPredict->setResult(predictionRes));

    const size_t nCols = (method == samme) ? 1 : nClasses;
    classifier::prediction::ResultId resultId = (method == samme) ?
            classifier::prediction::prediction :
            classifier::prediction::probabilities;

    DAAL_UINT64 resToEvaluate = (method == samme) ?
                                classifier::computeClassLabels :
                                classifier::computeClassProbabilities;

    learnerPredict->parameter().resultsToEvaluate = resToEvaluate;

    for(size_t i = 0; i < nWeakLearners; i++)
    {
        services::SharedPtr<HomoNTCPU > rWeakTable = HomoNTCPU::create(nCols, nVectors, &s);
        weakPredictions << rWeakTable;
        DAAL_CHECK_STATUS_VAR(s);
        learnerPredict->getResult()->set(resultId, rWeakTable);
        learnerInput->set(classifier::prediction::model, boostModel->getWeakLearnerModel(i));
        DAAL_CHECK_STATUS(s, learnerPredict->computeNoThrow());
    }

    services::SharedPtr<HomoNTCPU > curClassScoreTable = HomoNTCPU::create(1, nVectors, &s);
    algorithmFPType *curClassScore = curClassScoreTable->getArray();

    services::SharedPtr<HomoNTCPU > maxClassScoreTable = HomoNTCPU::create(1, nVectors, &s);
    algorithmFPType *maxClassScore = maxClassScoreTable->getArray();

    /* Initialize array of prediction results */
    for (size_t j = 0; j < nVectors; j++)
    {
        r[j] = 0;
        curClassScore[j] = 0;
        maxClassScore[j] = 0;
    }

    if(method == sammeR)
    {
        for(size_t m = 0; m < nWeakLearners; m++)
        {
            algorithmFPType *rWeak = weakPredictions[m]->getArray();
            computeSammeProbability(rWeak, nVectors, nClasses, rWeak);
        }
    }
    for(size_t k = 0; k < nClasses; k++)
    {
        for(size_t m = 0; m < nWeakLearners; m++)
        {
            const algorithmFPType *rWeak = weakPredictions[m]->getArray();
            for (size_t i = 0; i < nVectors; i++)
            {
                if(method == samme)
                {
                    curClassScore[i] += alpha[m] * (rWeak[i] == k);
                }
                else if(method == sammeR)
                {
                    curClassScore[i] += rWeak[i * nClasses + k];
                }

            }
        }
        for (size_t i = 0; i < nVectors; i++)
        {
            if(curClassScore[i] > maxClassScore[i])
            {
                r[i] = k;
                maxClassScore[i] = curClassScore[i];
            }
            curClassScore[i] = 0;
        }
    }
    if(nClasses == 2)
    {
        const algorithmFPType minusOne = (algorithmFPType)-1.0;
        const algorithmFPType zero = (algorithmFPType)0.0;
        for(size_t j = 0; j < nVectors; j++)
        {
            if(r[j] == zero) { r[j] = minusOne; }
        }
    }
    return s;
}

template <Method method, typename algorithmFPType, CpuType cpu>
services::Status AdaBoostPredictKernelNew<method, algorithmFPType, cpu>::compute(const NumericTablePtr &xTable,
        const Model *m, const NumericTablePtr &rTable, const Parameter *par)
{
    const size_t nVectors = xTable->getNumberOfRows();

    Model *boostModel = const_cast<Model *>(m);
    const size_t nWeakLearners = boostModel->getNumberOfWeakLearners();
    services::Status s;
    WriteOnlyColumns<algorithmFPType, cpu> mtR(*rTable, 0, 0, nVectors);
    DAAL_CHECK_BLOCK_STATUS(mtR);
    algorithmFPType *r = mtR.get();
    DAAL_ASSERT(r);

    const size_t nClasses = par->nClasses;
    {
        ReadColumns<algorithmFPType, cpu> mtAlpha(*boostModel->getAlpha(), 0, 0, nWeakLearners);
        DAAL_CHECK_BLOCK_STATUS(mtAlpha);
        DAAL_ASSERT(mtAlpha.get());
        if(method == samme && nClasses == 2)
        {
            DAAL_CHECK_STATUS(s, this->computeImpl(xTable, m, nWeakLearners, mtAlpha.get(), r, par));
        }
        else
        {
            DAAL_CHECK_STATUS(s, this->computeCommon(xTable, m, nWeakLearners, mtAlpha.get(), r, par));
        }
    }

    return s;
}

} // namespace daal::algorithms::adaboost::prediction::internal
}
}
}
} // namespace daal

#endif
