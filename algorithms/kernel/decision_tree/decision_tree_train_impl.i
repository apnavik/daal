/* file: decision_tree_train_impl.i */
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
//  Common functions for Decision tree training
//--
*/

#ifndef __DECISION_TREE_TRAIN_IMPL_I__
#define __DECISION_TREE_TRAIN_IMPL_I__

#include "numeric_table.h"
#include "threading.h"
#include "decision_tree_impl.i"
#include "service_utils.h"
#include "service_sort.h"
#include "service_math.h"
#include "service_data_utils.h"
#include "service_threading.h"
#include "data_management/features/defines.h"

namespace daal
{
namespace algorithms
{
namespace decision_tree
{
namespace internal
{

using namespace daal::data_management;
using namespace daal::services::internal;
using namespace daal::algorithms::internal;

typedef size_t TreeNodeIndex;
typedef size_t LeavesDataIndex;

template <CpuType cpu, typename IndependentVariable, typename DependentVariable>
class TreeNode
{
public:
    typedef IndependentVariable IndependentVariableType;
    typedef DependentVariable DependentVariableType;

    // Constructs leaf.
    TreeNode(DependentVariableType dependentVariable, LeavesDataIndex leavesDataIndex,
        double impurity, int count) : _leftChildIndex(0),
                                      _dependentVariable(dependentVariable),
                                      _leavesDataIndex(leavesDataIndex),
                                      _impurity(impurity),
                                      _count(count) {}

    // Constructs decision node.
    TreeNode(FeatureIndex featureIndex, IndependentVariableType cutPoint, TreeNodeIndex leftChildIndex,
        double impurity, int count) : _leftChildIndex(leftChildIndex),
                                      _featureIndex(featureIndex),
                                      _cutPoint(cutPoint),
                                      _impurity(impurity),
                                      _count(count)
    {
        DAAL_ASSERT(leftChildIndex != 0);
    }

    bool isLeaf() const { return (_leftChildIndex == 0); }

    TreeNodeIndex leftChildIndex() const
    {
        DAAL_ASSERT(!isLeaf());
        return _leftChildIndex;
    }

    TreeNodeIndex rightChildIndex() const
    {
        DAAL_ASSERT(!isLeaf());
        return _leftChildIndex + 1;
    }

    FeatureIndex featureIndex() const
    {
        DAAL_ASSERT(!isLeaf());
        return _featureIndex;
    }

    IndependentVariableType cutPoint() const
    {
        DAAL_ASSERT(!isLeaf());
        return _cutPoint;
    }

    DependentVariableType dependentVariable() const
    {
        DAAL_ASSERT(isLeaf());
        return _dependentVariable;
    }

    LeavesDataIndex leavesDataIndex() const
    {
        DAAL_ASSERT(isLeaf());
        return _leavesDataIndex;
    }

    double impurity() const
    {
        return _impurity;
    }

    int count() const
    {
        return _count;
    }

private:
    TreeNodeIndex _leftChildIndex;
    union
    {
        // Decision node.
        struct
        {
            FeatureIndex _featureIndex;
            IndependentVariableType _cutPoint;
        };

        // Leaf node.
        struct
        {
            DependentVariableType _dependentVariable;
            LeavesDataIndex _leavesDataIndex;
        };
    };

    double _impurity;
    int _count;
};

template <CpuType cpu>
struct BaseCutPointFinder
{
    template <typename SplitCriterion, typename RandomIterator, typename GetIndependentValue, typename GetDependentValue,  typename GetWeight, typename Compare>
    static RandomIterator find(SplitCriterion & splitCriterion, RandomIterator first, RandomIterator last,
                               typename SplitCriterion::DataStatistics & dataStatistics,
                               const typename SplitCriterion::DataStatistics & totalDataStatistics,
                               data_management::features::FeatureType featureType, RandomIterator & greater,
                               typename SplitCriterion::ValueType & winnerSplitCriterionValue,
                               typename SplitCriterion::DataStatistics & winnerDataStatistics,
                               GetIndependentValue getIndependentValue, GetDependentValue getDependentValue, GetWeight getWeight, Compare compare)
    {
        auto winner = last;
        if (first != last)
        {
            const size_t totalCount = last - first;
            if (featureType != data_management::features::DAAL_CATEGORICAL)
            {
                dataStatistics.reset(totalDataStatistics);
                for (auto i = first;;)
                {
                    const auto next = upperBound<cpu>(i, last, *i, compare);
                    if (next == last) { break; }

                    for (auto j = i; j != next; ++j)
                    {
                        dataStatistics.update(getDependentValue(*j));
                    }

                    const size_t leftCount = next - first;
                    const size_t rightCount = last - next;
                    DAAL_ASSERT(leftCount + rightCount == totalCount);

                    const auto splitCriterionValue = splitCriterion(first, last, i, next, dataStatistics, totalDataStatistics, featureType,
                                                                    leftCount, rightCount, totalCount);

                    if (!(winner != last) || (splitCriterionValue < winnerSplitCriterionValue))
                    {
                        winner = i;
                        greater = next;
                        winnerSplitCriterionValue = splitCriterionValue;
                        winnerDataStatistics = dataStatistics;
                    }

                    i = next;
                }
            }
            else
            {
                auto i = first;
                auto next = upperBound<cpu>(i, last, *i, compare);
                if (next != last)
                {
                    for (;; next = upperBound<cpu>(i, last, *i, compare))
                    {
                        dataStatistics.reset(totalDataStatistics);

                        for (auto j = i; j != next; ++j)
                        {
                            dataStatistics.update(getDependentValue(*j));
                        }

                        const size_t leftCount = next - i;
                        const size_t rightCount = totalCount - leftCount;
                        DAAL_ASSERT(rightCount == (i - first) + (last - next));

                        const auto splitCriterionValue = splitCriterion(first, last, i, next, dataStatistics, totalDataStatistics, featureType,
                                                                        leftCount, rightCount, totalCount);

                        if (!(winner != last) || (splitCriterionValue < winnerSplitCriterionValue))
                        {
                            winner = i;
                            greater = next;
                            winnerSplitCriterionValue = splitCriterionValue;
                            winnerDataStatistics = dataStatistics;
                        }

                        if (next == last) { break; }
                        i = next;
                    }
                }
            }
        }

        return winner;
    }
};

template <CpuType cpu>
struct WeightedBaseCutPointFinder
{
    template <typename SplitCriterion, typename RandomIterator, typename GetIndependentValue, typename GetDependentValue, typename GetWeight, typename Compare>
    static RandomIterator find(SplitCriterion & splitCriterion, RandomIterator first, RandomIterator last,
                               typename SplitCriterion::DataStatistics & dataStatistics,
                               const typename SplitCriterion::DataStatistics & totalDataStatistics,
                               data_management::features::FeatureType featureType, RandomIterator & greater,
                               typename SplitCriterion::ValueType & winnerSplitCriterionValue,
                               typename SplitCriterion::DataStatistics & winnerDataStatistics,
                               GetIndependentValue getIndependentValue, GetDependentValue getDependentValue, GetWeight getWeight, Compare compare)
    {
        double totalWeight = 0.0;
        const size_t statisticsSize = totalDataStatistics.size();
        for(size_t k = 0; k < statisticsSize; k++)
        {
            totalWeight += totalDataStatistics[k];
        }

        auto winner = last;
        if (first != last)
        {
            const size_t totalCount = last - first;
            if (featureType != data_management::features::DAAL_CATEGORICAL)
            {
                dataStatistics.reset(totalDataStatistics);
                for (auto i = first;;)
                {
                    const auto next = upperBound<cpu>(i, last, *i, compare);
                    if (next == last) { break; }

                    for (auto j = i; j != next; ++j)
                    {
                        dataStatistics.update(getDependentValue(*j), getWeight(*j));
                    }

                    double leftWeight = 0.0, rightWeight = 0.0;
                    for(size_t k = 0; k < statisticsSize; k++)
                    {
                        leftWeight += dataStatistics[k];
                    }
                    rightWeight = totalWeight - leftWeight;

                    const auto splitCriterionValue = splitCriterion(first, last, i, next, dataStatistics, totalDataStatistics, featureType,
                                                                    leftWeight, rightWeight, totalWeight);

                    if (!(winner != last) || (splitCriterionValue < winnerSplitCriterionValue))
                    {
                        winner = i;
                        greater = next;
                        winnerSplitCriterionValue = splitCriterionValue;
                        winnerDataStatistics = dataStatistics;
                    }

                    i = next;
                }
            }
            else
            {
                auto i = first;
                auto next = upperBound<cpu>(i, last, *i, compare);
                if (next != last)
                {
                    for (;; next = upperBound<cpu>(i, last, *i, compare))
                    {
                        dataStatistics.reset(totalDataStatistics);

                        for (auto j = i; j != next; ++j)
                        {
                            dataStatistics.update(getDependentValue(*j), getWeight(*j));
                        }

                        const size_t leftCount = next - i;
                        const size_t rightCount = totalCount - leftCount;
                        DAAL_ASSERT(rightCount == (i - first) + (last - next));

                        const auto splitCriterionValue = splitCriterion(first, last, i, next, dataStatistics, totalDataStatistics, featureType,
                                                                        leftCount, rightCount, totalCount);

                        if (!(winner != last) || (splitCriterionValue < winnerSplitCriterionValue))
                        {
                            winner = i;
                            greater = next;
                            winnerSplitCriterionValue = splitCriterionValue;
                            winnerDataStatistics = dataStatistics;
                        }

                        if (next == last) { break; }
                        i = next;
                    }
                }
            }
        }

        return winner;
    }
};

template <CpuType cpu, typename algorithmFPType, typename SplitCriterion>
struct CutPointFinder : private BaseCutPointFinder<cpu>
{
    using BaseCutPointFinder<cpu>::find;
};

template <typename WorkItem>
class WorkQueue
{
public:
    WorkQueue() : _capacity(1024), _capacityMinus1(_capacity - 1), _first(0), _last(_capacityMinus1), _size(0), _data(new WorkItem[_capacity]) {}

    WorkQueue(const WorkQueue &) = delete;

    ~WorkQueue() { delete[] _data; }

    size_t size() const { return _size; }

    bool empty() const { return (_size == 0); }

    WorkItem & front()
    {
        DAAL_ASSERT(!empty());

        return _data[_first];
    }

    void pop()
    {
        DAAL_ASSERT(!empty());

        ++_first;
        _first *= (_first != _capacity);
        --_size;
    }

    void push(const WorkItem & value)
    {
        if (_size == _capacity) { grow(); }
        DAAL_ASSERT(_size < _capacity);
        DAAL_ASSERT(((_capacityMinus1 + 1) & _capacityMinus1) == 0); // (_capacityMinus1 + 1) is power of 2.
        _data[_last = (_last + 1) & _capacityMinus1] = value;
        ++_size;
    }

private:
    void grow()
    {
        const size_t newCapacity = _capacity * 2;
        DAAL_ASSERT(_size < newCapacity);
        WorkItem * const newData = new WorkItem[newCapacity];
        size_t srcIdx = _first;
        for (size_t i = 0; i < _size; ++i)
        {
            newData[i].moveFrom(_data[srcIdx]);
            ++srcIdx;
            srcIdx *= (srcIdx != _capacity);
        }
        delete[] _data;
        _data = newData;
        _capacity = newCapacity;
        _capacityMinus1 = _capacity - 1;
        _first = 0;
        _last = _size != 0 ? _size - 1 : _capacityMinus1;
    }

    size_t _capacity;
    size_t _capacityMinus1;
    size_t _first;
    size_t _last;
    size_t _size;
    WorkItem * _data;
};

template <typename WorkItem>
class WorkStack
{
public:
    WorkStack() : _capacity(1024), _capacityMinus1(_capacity - 1), _size(0), _top(_capacityMinus1), _data(new WorkItem[_capacity]) {}

    WorkStack(const WorkStack &) = delete;

    ~WorkStack() { delete[] _data; }

    size_t size() const { return _size; }

    bool empty() const { return (_size == 0); }

    WorkItem & top()
    {
        DAAL_ASSERT(!empty());

        return _data[_top];
    }

    void pop()
    {
        DAAL_ASSERT(!empty());

        --_top;
        --_size;
    }

    void push(const WorkItem & value)
    {
        if (_size == _capacity) { grow(); }
        DAAL_ASSERT(_size < _capacity);
        _top = (_top + 1) & _capacityMinus1;
        _data[_top] = value;
        ++_size;
    }

private:
    void grow()
    {
        const size_t newCapacity = _capacity * 2;
        DAAL_ASSERT(_size < newCapacity);
        WorkItem * const newData = new WorkItem[newCapacity];
        for (size_t i = 0; i < _size; ++i)
        {
            newData[i].moveFrom(_data[i]);
        }
        delete[] _data;
        _data = newData;
        _capacity = newCapacity;
        _capacityMinus1 = _capacity - 1;
    }

    size_t _capacity;
    size_t _capacityMinus1;
    size_t _size;
    size_t _top;
    WorkItem * _data;
};

template <CpuType cpu, typename PerLeafData = void>
class LeavesData
{
public:
    LeavesData() : _data(nullptr), _size(0), _capacity(0) {}

    ~LeavesData() { delete[] _data; }

    template <typename T>
    LeavesDataIndex add(const T & value)
    {
        if (_size >= _capacity) { grow(); }
        DAAL_ASSERT(_size < _capacity);
        const LeavesDataIndex idx = _size;
        _data[idx] = value;
        ++_size;
        return idx;
    }

    void putProbabilities(LeavesDataIndex index, double * probs, size_t numProbs) const
    {
        (*this)[index].putProbabilities(probs, numProbs);
    }

    const PerLeafData & operator[] (size_t index) const
    {
        DAAL_ASSERT(index < _size);
        return _data[index];
    }

private:
    void grow()
    {
        const size_t newCapacity = (_capacity != 0) ? _capacity * 2 : 256;
        DAAL_ASSERT(_size < newCapacity);
        PerLeafData * const newData = new PerLeafData[newCapacity];
        for (size_t i = 0; i < _size; ++i)
        {
            newData[i].swap(_data[i]);
        }
        delete[] _data;
        _data = newData;
        _capacity = newCapacity;
    }

    PerLeafData * _data;
    size_t _size;
    size_t _capacity;
};

template <CpuType cpu>
class LeavesData<cpu, void>
{
public:
    template <typename T>
    LeavesDataIndex add(const T &) { return 0; }

    void putProbabilities(LeavesDataIndex index, double * probs, size_t numProbs) const {}
};

template <CpuType cpu, typename IndependentVariable, typename DependentVariable>
class Tree
{
public:
    typedef IndependentVariable IndependentVariableType;
    typedef DependentVariable DependentVariableType;
    typedef TreeNode<cpu, IndependentVariableType, DependentVariableType> TreeNodeType;

    Tree() : _nodes(nullptr), _nodeCount(0), _nodeCapacity(0) {}

    Tree(const Tree &) = delete;
    Tree & operator= (const Tree &) = delete;

    ~Tree()
    {
        daal_free(_nodes);
        _nodes = nullptr;
    }

    size_t nodeCount() const { return _nodeCount; }

    const TreeNodeType & operator[] (size_t index) const
    {
        DAAL_ASSERT(index < _nodeCount);
        return _nodes[index];
    }

    TreeNodeType & operator[] (size_t index)
    {
        DAAL_ASSERT(index < _nodeCount);
        return _nodes[index];
    }

    template <typename SplitCriterion, typename LeavesData>
    struct TrainigContext
    {
        typedef SplitCriterion SplitCriterionType;
        typedef LeavesData LeavesDataType;

        SplitCriterionType & splitCriterion;
        LeavesDataType & leavesData;
        const NumericTable & x;
        const NumericTable & y;
        const NumericTable * w;
        const FeatureTypesCache & featureTypesCache;
        typename SplitCriterionType::DataStatistics & dataStatistics;
        const size_t minLeafSize;
        const size_t minSplitSize;
        const IndependentVariableType * const * dx;
        const DependentVariableType * dy;
        const IndependentVariableType * dw;
    };

#include "decision_stump_train_impl.i"

    template <typename SplitCriterion, typename LeavesData>
    void train(SplitCriterion & splitCriterion, LeavesData & leavesData, const NumericTable & x, const NumericTable & y, const NumericTable * w,
               size_t numberOfClasses = 0, size_t maxTreeDepth = 0, size_t minLeafObservations = 1, size_t minSplitObservations = 2)
    {
        if(maxTreeDepth == 2) // stump with weights
        {
            return trainStump(splitCriterion, leavesData, x, y, w, numberOfClasses, minLeafObservations, minSplitObservations);
        }
        const size_t xRowCount = x.getNumberOfRows();
        const size_t xColumnCount = x.getNumberOfColumns();
        DAAL_ASSERT(xRowCount > 0);
        DAAL_ASSERT(xColumnCount > 0);
        DAAL_ASSERT(xRowCount == y.getNumberOfRows());

        FeatureTypesCache featureTypesCache(x);

        typename SplitCriterion::DataStatistics totalDataStatistics(numberOfClasses, x, y, w), dataStatistics(numberOfClasses, w);

        size_t * indexes = prepareIndexes(xRowCount);

        clear();

        BlockDescriptor<IndependentVariableType> * xBD = new BlockDescriptor<IndependentVariableType>[xColumnCount];
        const IndependentVariableType ** dx = new const IndependentVariableType * [xColumnCount];
        if(x.getDataLayout() == data_management::NumericTableIface::soa)
        {
            for (size_t i = 0; i < xColumnCount; ++i)
            {
                const_cast<NumericTable *>(&x)->getBlockOfColumnValues(i, 0, xRowCount, readOnly, xBD[i]);
                dx[i] = xBD[i].getBlockPtr();
            }
        }
        else
        {
            daal::threader_for(xColumnCount, xColumnCount, [=, &x, &xBD](size_t i)
            {
                const_cast<NumericTable *>(&x)->getBlockOfColumnValues(i, 0, xRowCount, readOnly, xBD[i]);
                dx[i] = xBD[i].getBlockPtr();
            });
        }
        BlockDescriptor<DependentVariableType> yBD;
        const_cast<NumericTable *>(&y)->getBlockOfColumnValues(0, 0, xRowCount, readOnly, yBD);

        BlockDescriptor<IndependentVariableType> wBD;
        if (w) { const_cast<NumericTable *>(w)->getBlockOfColumnValues(0, 0, xRowCount, readOnly, wBD);}

        const size_t depthLimit = (maxTreeDepth != 0) ? maxTreeDepth : static_cast<size_t>(-1);
        const TrainigContext<SplitCriterion, LeavesData> context{ splitCriterion, leavesData, x, y, w, featureTypesCache, dataStatistics,
                                                                  minLeafObservations, minSplitObservations, dx, yBD.getBlockPtr(),
                                                                  wBD.getBlockPtr() };
        if (xColumnCount < threader_get_threads_number())
        {
            internalTrainFewFeatures(context, indexes, xRowCount, pushBack(), totalDataStatistics, depthLimit);
        }
        else
        {
            internalTrainManyFeatures(context, indexes, xRowCount, pushBack(), totalDataStatistics, depthLimit);
        }

        if (w) { const_cast<NumericTable *>(w)->releaseBlockOfColumnValues(wBD); }
        const_cast<NumericTable *>(&y)->releaseBlockOfColumnValues(yBD);
        for (size_t i = 0; i < xColumnCount; ++i)
        {
            const_cast<NumericTable *>(&x)->releaseBlockOfColumnValues(xBD[i]);
        }

        delete[] dx;
        delete[] xBD;
        daal_free(indexes);
        indexes = nullptr;
        dx      = nullptr;
        xBD     = nullptr;
    }

    template <typename SplitCriterion>
    void train(SplitCriterion & splitCriterion, const NumericTable & x, const NumericTable & y, const NumericTable * w,
               size_t numberOfClasses = 0, size_t maxTreeDepth = 0, size_t minLeafObservations = 1, size_t minSplitObservations = 2)
    {
        LeavesData<cpu, void> leavesData;
        train(splitCriterion, leavesData, x, y, w, numberOfClasses, maxTreeDepth, minLeafObservations, minSplitObservations);
    }

    template <typename Data>
    void reducedErrorPruning(const NumericTable & px, const NumericTable & py, Data & data) const
    {
        typedef typename Data::ErrorType ErrorType;

        if (!empty())
        {
            DAAL_ASSERT(_nodeCount == data.size());

            FeatureTypesCache featureTypesCache(px);

            const size_t pxRowCount = px.getNumberOfRows();
            const size_t pxColumnCount = px.getNumberOfColumns();
            DAAL_ASSERT(pxRowCount == py.getNumberOfRows());
            BlockDescriptor<IndependentVariableType> pxBD;
            BlockDescriptor<DependentVariableType> pyBD;
            const_cast<NumericTable &>(px).getBlockOfRows(0, pxRowCount, readOnly, pxBD);
            const_cast<NumericTable &>(py).getBlockOfColumnValues(0, 0, pxRowCount, readOnly, pyBD);
            const IndependentVariableType * const dpx = pxBD.getBlockPtr();
            const DependentVariableType * const dpy = pyBD.getBlockPtr();

            for (size_t i = 0; i < pxRowCount; ++i)
            {
                const IndependentVariableType * const p = &dpx[i * pxColumnCount];
                size_t nodeIdx = 0;
                DAAL_ASSERT(nodeIdx < _nodeCount);
                while (!_nodes[nodeIdx].isLeaf())
                {
                    data.update(nodeIdx, dpy[i]);
                    const size_t nodeFeatureIndex = _nodes[nodeIdx].featureIndex();
                    switch (featureTypesCache[nodeFeatureIndex])
                    {
                    case data_management::features::DAAL_CATEGORICAL:
                        nodeIdx = (p[nodeFeatureIndex] == _nodes[nodeIdx].cutPoint() ? _nodes[nodeIdx].leftChildIndex()
                                                                                     : _nodes[nodeIdx].rightChildIndex());
                        DAAL_ASSERT(nodeIdx < _nodeCount);
                        break;
                    case data_management::features::DAAL_ORDINAL:
                    case data_management::features::DAAL_CONTINUOUS:
                        nodeIdx = (p[nodeFeatureIndex] < _nodes[nodeIdx].cutPoint() ? _nodes[nodeIdx].leftChildIndex()
                                                                                    : _nodes[nodeIdx].rightChildIndex());
                        DAAL_ASSERT(nodeIdx < _nodeCount);
                        break;
                    default:
                        DAAL_ASSERT(false);
                        break;
                    }
                }

                data.update(nodeIdx, dpy[i]);
            }

            const_cast<NumericTable &>(py).releaseBlockOfColumnValues(pyBD);
            const_cast<NumericTable &>(px).releaseBlockOfRows(pxBD);

            internalREP<ErrorType, Data>(0, data);
        }
    }

protected:
    void reserve(size_t newCapacity)
    {
        if (newCapacity > _nodeCapacity)
        {
            TreeNodeType * newNodes = daal_alloc<TreeNodeType>(newCapacity);
            daal_memcpy_s(newNodes, newCapacity * sizeof(TreeNodeType), _nodes, _nodeCount * sizeof(TreeNodeType));
            swap<cpu>(_nodes, newNodes);
            swap<cpu>(_nodeCapacity, newCapacity);
            daal_free(newNodes);
            newNodes = nullptr;
        }
    }

    TreeNodeIndex pushBack()
    {
        if (_nodeCount >= _nodeCapacity)
        {
            reserve(max<cpu>(_nodeCount + 1, _nodeCapacity * 2));
        }

        return _nodeCount++;
    }

    void clear()
    {
        _nodeCount = 0;
    }

    bool empty() const { return (_nodeCount == 0); }

    size_t * prepareIndexes(size_t size)
    {
        size_t * const indexes = daal_alloc<size_t>(size);
        for (size_t i = 0; i < size; ++i)
        {
            indexes[i] = i;
        }
        return indexes;
    }

    void makeLeaf(TreeNodeIndex nodeIndex, DependentVariableType dependentVariable, LeavesDataIndex leavesDataIndex, double impurity, int count)
    {
        const TreeNodeType tmp(dependentVariable, leavesDataIndex, impurity, count);
        _nodes[nodeIndex] = tmp;
        DAAL_ASSERT(_nodes[nodeIndex].isLeaf());
        DAAL_ASSERT(_nodes[nodeIndex].dependentVariable() == dependentVariable);
        DAAL_ASSERT(_nodes[nodeIndex].leavesDataIndex() == leavesDataIndex);
    }

    void makeSplit(TreeNodeIndex nodeIndex, FeatureIndex featureIndex, IndependentVariable cutPoint, double impurity, int count)
    {
        const TreeNodeType tmp(featureIndex, cutPoint, pushBack(), impurity, count);
        _nodes[nodeIndex] = tmp;
        pushBack();
        DAAL_ASSERT(!_nodes[nodeIndex].isLeaf());
        DAAL_ASSERT(_nodes[nodeIndex].featureIndex() == featureIndex);
        DAAL_ASSERT(_nodes[nodeIndex].cutPoint() == cutPoint);
        DAAL_ASSERT(_nodes[nodeIndex].leftChildIndex() == _nodeCount - 2);
        DAAL_ASSERT(_nodes[nodeIndex].rightChildIndex() == _nodeCount - 1);
    }

    template <typename SplitCriterion, typename LeavesData>
    void internalTrainManyFeatures(const TrainigContext<SplitCriterion, LeavesData> & context, size_t * indexes, size_t indexCount,
                                   TreeNodeIndex nodeIndex, const typename SplitCriterion::DataStatistics & totalDataStatistics, size_t depthLimit)
    {
        typedef data_management::BlockDescriptor<IndependentVariableType> IndependentVariableBD;
        typedef data_management::BlockDescriptor<DependentVariableType> DependentVariableBD;
        typedef daal::internal::Math<typename SplitCriterion::ValueType, cpu> SplitCriterionMath;
        typedef daal::services::internal::EpsilonVal<typename SplitCriterion::ValueType> SplitCriterionEpsilon;

        DAAL_ASSERT(depthLimit != 0);
        DAAL_ASSERT(context.minLeafSize >= 1);
        DAAL_ASSERT(indexes);
        DAAL_ASSERT(context.dx);
        DAAL_ASSERT(context.dy);
        DAAL_ASSERT((context.w == nullptr) == (context.dw == nullptr));

        if (depthLimit == 1 || indexCount < context.minSplitSize || indexCount < context.minLeafSize * 2)
        {
            makeLeaf(nodeIndex, totalDataStatistics.getBestDependentVariableValue(), context.leavesData.add(totalDataStatistics),
                     static_cast<double>(context.splitCriterion(totalDataStatistics, indexCount)), static_cast<int>(indexCount));
            return;
        }

        {
            typename SplitCriterion::DependentVariableType leafDependentVariableValue;
            if (totalDataStatistics.isPure(leafDependentVariableValue))
            {
                makeLeaf(nodeIndex, leafDependentVariableValue, context.leavesData.add(totalDataStatistics),
                         static_cast<double>(context.splitCriterion(totalDataStatistics, indexCount)), static_cast<int>(indexCount));
                return;
            }
        }

        FeatureIndex winnerFeatureIndex = 0;
        IndependentVariableType winnerCutPoint;
        typename SplitCriterion::ValueType winnerSplitCriterionValue, splitCriterionValue;
        size_t winnerPointsAtLeft;
        typename SplitCriterion::DataStatistics winnerDataStatistics, bestCutPointDataStatistics;
        bool winnerIsLeaf = true;

        const size_t featureCount = context.x.getNumberOfColumns();

        struct Item
        {
            IndependentVariable x;
            IndependentVariable w;
            DependentVariable y;
        };

        struct Local
        {
            FeatureIndex winnerFeatureIndex;
            IndependentVariableType winnerCutPoint;
            typename SplitCriterion::ValueType winnerSplitCriterionValue, splitCriterionValue;
            size_t winnerPointsAtLeft;
            typename SplitCriterion::DataStatistics winnerDataStatistics, bestCutPointDataStatistics, dataStatistics;
            bool winnerIsLeaf;
            SplitCriterion splitCriterion;

            Local(const SplitCriterion & criterion) : winnerIsLeaf(true), splitCriterion(criterion)  {}
        };

        daal::tls<Local *> localTLS([=, &context]()-> Local *
        {
            Local * const ptr = new Local(context.splitCriterion);
            return ptr;
        } );

        const typename SplitCriterion::ValueType epsilon = SplitCriterionEpsilon::get();

        daal::threader_for(featureCount, featureCount,
         [=, &localTLS, &context, &indexes, &totalDataStatistics](int featureIndex)
        {
            Local * const local = localTLS.local();

            Item * items = daal_alloc<Item>(indexCount);

            const size_t rowsPerBlock = 512;
            const size_t blockCount = (indexCount + rowsPerBlock - 1) / rowsPerBlock;
            for(size_t iBlock = 0; iBlock < blockCount; iBlock++)
            {
                const size_t first = iBlock * rowsPerBlock;
                const size_t last = min<cpu>(first + rowsPerBlock, indexCount);

                for (size_t i = first; i < last; ++i)
                {
                    items[i].x = context.dx[featureIndex][indexes[i]];
                    items[i].y = context.dy[indexes[i]];
                }
                if (context.dw)
                {
                    for (size_t i = first; i < last; ++i)
                    {
                        items[i].w = context.dw[indexes[i]];
                    }
                }
            }

            introSort<cpu>(items, &items[indexCount], [](const Item & v1, const Item & v2) -> bool
            {
                return v1.x < v2.x;
            });
            DAAL_ASSERT(isSorted<cpu>(items, &items[indexCount], [](const Item & v1, const Item & v2) -> bool
                {
                    return v1.x < v2.x;
                }));

            Item * next = nullptr;
            const auto i = CutPointFinder<cpu, IndependentVariableType, SplitCriterion>::find(local->splitCriterion, items, &items[indexCount], local->dataStatistics,
                                                                     totalDataStatistics,
                                                                     context.featureTypesCache[featureIndex], next, local->splitCriterionValue,
                                                                     local->bestCutPointDataStatistics,
                                                                     [](const Item & v) -> IndependentVariableType { return v.x; },
                                                                     [](const Item & v) -> DependentVariable { return v.y; },
                                                                     [](const Item & v) -> IndependentVariableType { return v.w; },
                                                                     [](const Item & v1, const Item & v2) -> bool { return v1.x < v2.x; });

            if (i != &items[indexCount] && (local->winnerIsLeaf || local->splitCriterionValue < local->winnerSplitCriterionValue ||
                                            (SplitCriterionMath::sFabs(local->splitCriterionValue - local->winnerSplitCriterionValue) <= epsilon &&
                                             local->winnerFeatureIndex > featureIndex)))
            {
                local->winnerIsLeaf = false;
                local->winnerFeatureIndex = featureIndex;
                local->winnerSplitCriterionValue = local->splitCriterionValue;
                switch (context.featureTypesCache[featureIndex])
                {
                case data_management::features::DAAL_CATEGORICAL:
                    local->winnerCutPoint = i->x;
                    break;
                case data_management::features::DAAL_ORDINAL:
                    local->winnerCutPoint = next->x;
                    break;
                case data_management::features::DAAL_CONTINUOUS:
                    local->winnerCutPoint = (i->x + next->x) / 2;
                    break;
                default:
                    DAAL_ASSERT(false);
                    break;
                }
                local->winnerPointsAtLeft = next - items; // distance.
                local->winnerDataStatistics = local->bestCutPointDataStatistics;
            }

            daal_free(items);
            items = nullptr;
        } );

        localTLS.reduce([=, &winnerIsLeaf, &winnerSplitCriterionValue, &winnerFeatureIndex, &winnerCutPoint, &winnerPointsAtLeft,
                         &winnerDataStatistics](Local * v) -> void
        {
            if ((!v->winnerIsLeaf) && (winnerIsLeaf || v->winnerSplitCriterionValue < winnerSplitCriterionValue ||
                                       (SplitCriterionMath::sFabs(winnerSplitCriterionValue - v->winnerSplitCriterionValue) <= epsilon &&
                                        winnerFeatureIndex > v->winnerFeatureIndex)))
            {
                winnerIsLeaf = false;
                winnerFeatureIndex = v->winnerFeatureIndex;
                winnerSplitCriterionValue = v->winnerSplitCriterionValue;
                winnerCutPoint = v->winnerCutPoint;
                winnerPointsAtLeft = v->winnerPointsAtLeft;
                winnerDataStatistics = v->winnerDataStatistics;
            }

            delete v;
            v = nullptr;
        } );

        if (winnerIsLeaf || winnerPointsAtLeft < context.minLeafSize || indexCount - winnerPointsAtLeft < context.minLeafSize)
        {
            makeLeaf(nodeIndex, totalDataStatistics.getBestDependentVariableValue(), context.leavesData.add(totalDataStatistics),
                     static_cast<double>(context.splitCriterion(totalDataStatistics, indexCount)), static_cast<int>(indexCount));
            return;
        }

        makeSplit(nodeIndex, winnerFeatureIndex, winnerCutPoint, static_cast<double>(context.splitCriterion(totalDataStatistics, indexCount)),
                  static_cast<int>(indexCount));
        DAAL_ASSERT(!_nodes[nodeIndex].isLeaf());

        // Partition.
        size_t * splitIndexes = nullptr;
        switch (context.featureTypesCache[winnerFeatureIndex])
        {
        case data_management::features::DAAL_CATEGORICAL:
            splitIndexes = partition<cpu>(indexes, &indexes[indexCount], [winnerFeatureIndex, winnerCutPoint, &context](size_t i) -> bool
            {
                return (context.dx[winnerFeatureIndex][i] == winnerCutPoint);
            });
            break;

        case data_management::features::DAAL_ORDINAL:
        case data_management::features::DAAL_CONTINUOUS:
            splitIndexes = partition<cpu>(indexes, &indexes[indexCount], [winnerFeatureIndex, winnerCutPoint, &context](size_t i) -> bool
            {
                return (context.dx[winnerFeatureIndex][i] < winnerCutPoint);
            });
            break;

        default:
            DAAL_ASSERT(false);
            break;
        }

        // Estimate data statistics after partitioning.
        typename SplitCriterion::DataStatistics & leftDataStatistics = winnerDataStatistics;
        typename SplitCriterion::DataStatistics rightDataStatistics(totalDataStatistics);
        rightDataStatistics -= leftDataStatistics;

        // Process left child.
        internalTrainManyFeatures(context, indexes, splitIndexes - indexes, _nodes[nodeIndex].leftChildIndex(), leftDataStatistics, depthLimit - 1);

        // Process right child.
        internalTrainManyFeatures(context, splitIndexes, &indexes[indexCount] - splitIndexes, _nodes[nodeIndex].rightChildIndex(),
                                  rightDataStatistics, depthLimit - 1);
    }

    template <typename SplitCriterion, typename LeavesData>
    void internalTrainFewFeatures(const TrainigContext<SplitCriterion, LeavesData> & context, size_t * indexes, size_t indexCount,
                                  TreeNodeIndex nodeIndex, const typename SplitCriterion::DataStatistics & totalDataStatistics, size_t depthLimit)
    {
        typedef typename SplitCriterion::DataStatistics DataStatistics;

        DAAL_ASSERT(depthLimit != 0);
        DAAL_ASSERT(context.minLeafSize >= 1);
        DAAL_ASSERT(indexes);
        DAAL_ASSERT(context.dx);
        DAAL_ASSERT(context.dy);
        DAAL_ASSERT((context.w == nullptr) == (context.dw == nullptr));

        struct WorkItem
        {
            DataStatistics totalDataStatistics;
            size_t firstIndex;
            size_t lastIndex;
            size_t depthLimit;
            TreeNodeIndex nodeIndex;

            WorkItem() {}

            WorkItem(const DataStatistics & stat, size_t firstIdx, size_t lastIdx, size_t depthLmt, TreeNodeIndex nodeIdx, const NumericTable * w)
                : totalDataStatistics(stat), firstIndex(firstIdx), lastIndex(lastIdx), depthLimit(depthLmt), nodeIndex(nodeIdx) {}

            void moveFrom(WorkItem & src)
            {
                DAAL_ASSERT(this != &src);

                firstIndex = src.firstIndex;
                lastIndex = src.lastIndex;
                depthLimit = src.depthLimit;
                nodeIndex = src.nodeIndex;
                totalDataStatistics.swap(src.totalDataStatistics);
            }
        };

        const size_t featureCount = context.x.getNumberOfColumns();
        FeatureIndex winnerFeatureIndex = 0;
        IndependentVariableType winnerCutPoint;
        typename SplitCriterion::ValueType winnerSplitCriterionValue;
        size_t winnerPointsAtLeft;
        typename SplitCriterion::DataStatistics winnerDataStatistics;

        WorkItem leftChild, rightChild;

        WorkQueue<WorkItem> workQueue;
        workQueue.push(WorkItem(totalDataStatistics, 0, indexCount, depthLimit, nodeIndex, context.w));

        typename SplitCriterion::DependentVariableType leafDependentVariableValue;
        const size_t maxThreads = threader_get_threads_number();
        const size_t workItemCountForDataParallel = max<cpu, size_t>(maxThreads / 4, 2);
        while (workQueue.size() < workItemCountForDataParallel)
        {
            if (workQueue.size() == 1)
            {
                WorkItem & workItem = workQueue.front();
                const size_t indexCnt = workItem.lastIndex - workItem.firstIndex;
                const IndependentVariableType sumWeights = workItem.totalDataStatistics.sumWeights(workItem.firstIndex, workItem.lastIndex,
                                                                                                   const_cast<NumericTable*>(context.w));
                if (workItem.depthLimit == 1 || indexCnt < context.minSplitSize || indexCnt < context.minLeafSize * 2)
                {
                    makeLeaf(workItem.nodeIndex, workItem.totalDataStatistics.getBestDependentVariableValue(),
                             context.leavesData.add(workItem.totalDataStatistics),
                             static_cast<double>(context.splitCriterion(workItem.totalDataStatistics, sumWeights)), static_cast<int>(indexCnt));
                    workQueue.pop();
                    DAAL_CHECK_BREAK((workQueue.empty()));
                }
                else if (workItem.totalDataStatistics.isPure(leafDependentVariableValue))
                {
                    makeLeaf(workItem.nodeIndex, leafDependentVariableValue, context.leavesData.add(workItem.totalDataStatistics),
                             static_cast<double>(context.splitCriterion(workItem.totalDataStatistics, sumWeights)), static_cast<int>(indexCnt));
                    workQueue.pop();
                    DAAL_CHECK_BREAK((workQueue.empty()));
                }
                else
                {
                    const bool winnerIsLeaf = !findSplitInParallel(context.splitCriterion, &indexes[workItem.firstIndex],
                                                                   workItem.lastIndex - workItem.firstIndex, context.featureTypesCache,
                                                                   workItem.totalDataStatistics, context.dx, context.dy, context.dw, featureCount,
                                                                   winnerFeatureIndex, winnerCutPoint, winnerSplitCriterionValue, winnerPointsAtLeft,
                                                                   winnerDataStatistics);
                    if (winnerIsLeaf || winnerPointsAtLeft < context.minLeafSize || indexCnt - winnerPointsAtLeft < context.minLeafSize)
                    {
                        makeLeaf(workItem.nodeIndex, workItem.totalDataStatistics.getBestDependentVariableValue(),
                                 context.leavesData.add(workItem.totalDataStatistics),
                                 static_cast<double>(context.splitCriterion(workItem.totalDataStatistics, sumWeights)), static_cast<int>(indexCnt));
                        workQueue.pop();
                        DAAL_CHECK_BREAK((workQueue.empty()));
                    }
                    else
                    {
                        makeSplit(workItem.nodeIndex, winnerFeatureIndex, winnerCutPoint,
                                  static_cast<double>(context.splitCriterion(workItem.totalDataStatistics, sumWeights)), static_cast<int>(indexCnt));
                        DAAL_ASSERT(!_nodes[workItem.nodeIndex].isLeaf());

                        // Partition.
                        size_t * splitIndexes = nullptr;
                        switch (context.featureTypesCache[winnerFeatureIndex])
                        {
                        case data_management::features::DAAL_CATEGORICAL:
                            splitIndexes = partition<cpu>(&indexes[workItem.firstIndex], &indexes[workItem.lastIndex],
                                                          [winnerFeatureIndex, winnerCutPoint, &context](size_t i) -> bool
                                                          { return (context.dx[winnerFeatureIndex][i] == winnerCutPoint); });
                            break;

                        case data_management::features::DAAL_ORDINAL:
                        case data_management::features::DAAL_CONTINUOUS:
                            splitIndexes = partition<cpu>(&indexes[workItem.firstIndex], &indexes[workItem.lastIndex],
                                                          [winnerFeatureIndex, winnerCutPoint, &context](size_t i) -> bool
                                                          { return (context.dx[winnerFeatureIndex][i] < winnerCutPoint); });
                            break;

                        default:
                            DAAL_ASSERT(false);
                            break;
                        }
                        DAAL_ASSERT(splitIndexes != nullptr);
                        DAAL_ASSERT(splitIndexes >= &indexes[workItem.firstIndex]);
                        DAAL_ASSERT(splitIndexes <= &indexes[workItem.lastIndex]);


                        leftChild.firstIndex = workItem.firstIndex;
                        leftChild.lastIndex = splitIndexes - indexes;
                        leftChild.depthLimit = workItem.depthLimit - 1;
                        leftChild.nodeIndex = _nodes[workItem.nodeIndex].leftChildIndex();
                        leftChild.totalDataStatistics.swap(winnerDataStatistics);

                        rightChild.firstIndex = leftChild.lastIndex;
                        rightChild.lastIndex = workItem.lastIndex;
                        rightChild.depthLimit = leftChild.depthLimit;
                        rightChild.nodeIndex = _nodes[workItem.nodeIndex].rightChildIndex();
                        rightChild.totalDataStatistics.swap(workItem.totalDataStatistics);
                        rightChild.totalDataStatistics -= leftChild.totalDataStatistics;

                        workQueue.pop();
                        workQueue.push(leftChild);
                        workQueue.push(rightChild);
                    }
                }
            }
            else
            {
                daal::Mutex mutex;
                const size_t workSize = workQueue.size();
                WorkItem * const workArray = new WorkItem[workSize];
                for (size_t i = 0; i < workSize; ++i)
                {
                    WorkItem & src = workQueue.front();
                    WorkItem & dest = workArray[i];
                    dest.moveFrom(src);
                    workQueue.pop();
                }

                daal::threader_for(workSize, workSize, [=, &workArray, &indexes, &mutex, &workQueue, &indexCount, &context](int iBlock)
                {
                    SplitCriterion localSplitCriterion(context.splitCriterion);
                    typename SplitCriterion::DependentVariableType leafDependentVariableValue;
                    WorkItem leftChild, rightChild;

                    FeatureIndex winnerFeatureIndex = 0;
                    IndependentVariableType winnerCutPoint;
                    typename SplitCriterion::ValueType winnerSplitCriterionValue;
                    size_t winnerPointsAtLeft;
                    typename SplitCriterion::DataStatistics winnerDataStatistics;

                    WorkItem & workItem = workArray[iBlock];
                    const size_t indexCnt = workItem.lastIndex - workItem.firstIndex;
                    const IndependentVariableType sumWeights = workItem.totalDataStatistics.sumWeights(workItem.firstIndex, workItem.lastIndex,
                                                                                                       const_cast<NumericTable *>(context.w));
                    if (workItem.depthLimit == 1 || indexCnt < context.minSplitSize || indexCnt < context.minLeafSize * 2)
                    {
                        AUTOLOCK(mutex);
                        makeLeaf(workItem.nodeIndex, workItem.totalDataStatistics.getBestDependentVariableValue(),
                                 context.leavesData.add(workItem.totalDataStatistics),
                                 static_cast<double>(localSplitCriterion(workItem.totalDataStatistics, sumWeights)), static_cast<int>(indexCnt));
                    }
                    else if (workItem.totalDataStatistics.isPure(leafDependentVariableValue))
                    {
                        AUTOLOCK(mutex);
                        makeLeaf(workItem.nodeIndex, leafDependentVariableValue, context.leavesData.add(workItem.totalDataStatistics),
                            static_cast<double>(localSplitCriterion(workItem.totalDataStatistics, sumWeights)), static_cast<int>(indexCnt));
                    }
                    else
                    {
                        const bool winnerIsLeaf = !findSplitInParallel(localSplitCriterion, &indexes[workItem.firstIndex],
                                                                       workItem.lastIndex - workItem.firstIndex, context.featureTypesCache,
                                                                       workItem.totalDataStatistics, context.dx, context.dy, context.dw,
                                                                       featureCount, winnerFeatureIndex, winnerCutPoint, winnerSplitCriterionValue,
                                                                       winnerPointsAtLeft, winnerDataStatistics);
                        if (winnerIsLeaf || winnerPointsAtLeft < context.minLeafSize || indexCnt - winnerPointsAtLeft < context.minLeafSize)
                        {
                            AUTOLOCK(mutex);
                            makeLeaf(workItem.nodeIndex, workItem.totalDataStatistics.getBestDependentVariableValue(),
                                     context.leavesData.add(workItem.totalDataStatistics),
                                     static_cast<double>(localSplitCriterion(workItem.totalDataStatistics, sumWeights)), static_cast<int>(indexCnt));
                        }
                        else
                        {
                            {
                                AUTOLOCK(mutex);
                                makeSplit(workItem.nodeIndex, winnerFeatureIndex, winnerCutPoint,
                                    static_cast<double>(localSplitCriterion(workItem.totalDataStatistics, sumWeights)), static_cast<int>(indexCnt));
                                DAAL_ASSERT(!_nodes[workItem.nodeIndex].isLeaf());
                                leftChild.nodeIndex = _nodes[workItem.nodeIndex].leftChildIndex();
                                rightChild.nodeIndex = _nodes[workItem.nodeIndex].rightChildIndex();
                            }

                            // Partition.
                            size_t * splitIndexes = nullptr;
                            switch (context.featureTypesCache[winnerFeatureIndex])
                            {
                            case data_management::features::DAAL_CATEGORICAL:
                                splitIndexes = partition<cpu>(&indexes[workItem.firstIndex], &indexes[workItem.lastIndex],
                                                              [winnerFeatureIndex, winnerCutPoint, &context](size_t i) -> bool
                                                              { return (context.dx[winnerFeatureIndex][i] == winnerCutPoint); });
                                break;

                            case data_management::features::DAAL_ORDINAL:
                            case data_management::features::DAAL_CONTINUOUS:
                                splitIndexes = partition<cpu>(&indexes[workItem.firstIndex], &indexes[workItem.lastIndex],
                                                              [winnerFeatureIndex, winnerCutPoint, &context](size_t i) -> bool
                                                              { return (context.dx[winnerFeatureIndex][i] < winnerCutPoint); });
                                break;

                            default:
                                DAAL_ASSERT(false);
                                break;
                            }
                            DAAL_ASSERT(splitIndexes != nullptr);
                            DAAL_ASSERT(splitIndexes >= &indexes[workItem.firstIndex]);
                            DAAL_ASSERT(splitIndexes <= &indexes[workItem.lastIndex]);

                            leftChild.firstIndex = workItem.firstIndex;
                            leftChild.lastIndex = splitIndexes - indexes;
                            leftChild.depthLimit = workItem.depthLimit - 1;
                            leftChild.totalDataStatistics.swap(winnerDataStatistics);

                            rightChild.firstIndex = leftChild.lastIndex;
                            rightChild.lastIndex = workItem.lastIndex;
                            rightChild.depthLimit = leftChild.depthLimit;
                            rightChild.totalDataStatistics.swap(workItem.totalDataStatistics);
                            rightChild.totalDataStatistics -= leftChild.totalDataStatistics;

                            {
                                AUTOLOCK(mutex);
                                workQueue.push(leftChild);
                                workQueue.push(rightChild);
                            }
                        }
                    }
                });

                delete[] workArray;
                if (workQueue.empty()) { break; }
            }
        };

        if (!workQueue.empty())
        {
            daal::Mutex mutex;
            const size_t workSize = workQueue.size();
            WorkItem * const workArray = new WorkItem[workSize];
            for (size_t i = 0; i < workSize; ++i)
            {
                WorkItem & src = workQueue.front();
                WorkItem & dest = workArray[i];
                dest.firstIndex = src.firstIndex;
                dest.lastIndex = src.lastIndex;
                dest.depthLimit = src.depthLimit;
                dest.nodeIndex = src.nodeIndex;
                dest.totalDataStatistics.swap(src.totalDataStatistics);
                workQueue.pop();
            }

            const size_t rowsPerBlock = (workSize + maxThreads - 1) / maxThreads;
            const size_t blockCount = (workSize + rowsPerBlock - 1) / rowsPerBlock;
            daal::threader_for(blockCount, blockCount, [=, &workArray, &indexes, &mutex, &indexCount, &context](int iBlock)
            {
                const size_t first = iBlock * rowsPerBlock;
                const size_t last = min<cpu>(first + rowsPerBlock, workSize);

                SplitCriterion localSplitCriterion(context.splitCriterion);
                typename SplitCriterion::DependentVariableType leafDependentVariableValue;

                WorkStack<WorkItem> workStack;

                WorkItem leftChild, rightChild;

                FeatureIndex winnerFeatureIndex = 0;
                IndependentVariableType winnerCutPoint;
                typename SplitCriterion::ValueType winnerSplitCriterionValue;
                size_t winnerPointsAtLeft;
                typename SplitCriterion::DataStatistics winnerDataStatistics;

                for (size_t i = first; i < last; ++i)
                {
                    workStack.push(workArray[i]);

                    for (;;)
                    {
                        WorkItem & workItem = workStack.top();

                        const size_t indexCnt = workItem.lastIndex - workItem.firstIndex;
                        const IndependentVariableType sumWeights = workItem.totalDataStatistics.sumWeights(workItem.firstIndex, workItem.lastIndex,
                                                                                                           const_cast<NumericTable *>(context.w));
                        if (workItem.depthLimit == 1 || indexCnt < context.minSplitSize || indexCnt < context.minLeafSize * 2)
                        {
                            {
                                AUTOLOCK(mutex);
                                makeLeaf(workItem.nodeIndex, workItem.totalDataStatistics.getBestDependentVariableValue(),
                                         context.leavesData.add(workItem.totalDataStatistics),
                                         static_cast<double>(localSplitCriterion(workItem.totalDataStatistics, sumWeights)),
                                         static_cast<int>(indexCnt));
                            }
                            workStack.pop();
                            if (workStack.empty()) { break; }
                        }
                        else if (workItem.totalDataStatistics.isPure(leafDependentVariableValue))
                        {
                            {
                                AUTOLOCK(mutex);
                                makeLeaf(workItem.nodeIndex, leafDependentVariableValue, context.leavesData.add(workItem.totalDataStatistics),
                                    static_cast<double>(localSplitCriterion(workItem.totalDataStatistics, sumWeights)), static_cast<int>(indexCnt));
                            }
                            workStack.pop();
                            if (workStack.empty()) { break; }
                        }
                        else
                        {
                            const bool winnerIsLeaf = !findSplitInSerial(localSplitCriterion, &indexes[workItem.firstIndex],
                                                                         workItem.lastIndex - workItem.firstIndex, context.featureTypesCache,
                                                                         workItem.totalDataStatistics, context.dx, context.dy, context.dw,
                                                                         featureCount, winnerFeatureIndex, winnerCutPoint, winnerSplitCriterionValue,
                                                                         winnerPointsAtLeft, winnerDataStatistics);
                            if (winnerIsLeaf || winnerPointsAtLeft < context.minLeafSize || indexCnt - winnerPointsAtLeft < context.minLeafSize)
                            {
                                {
                                    AUTOLOCK(mutex);
                                    makeLeaf(workItem.nodeIndex, workItem.totalDataStatistics.getBestDependentVariableValue(),
                                             context.leavesData.add(workItem.totalDataStatistics),
                                             static_cast<double>(localSplitCriterion(workItem.totalDataStatistics, sumWeights)),
                                             static_cast<int>(indexCnt));
                                }
                                workStack.pop();
                                if (workStack.empty()) { break; }
                            }
                            else
                            {
                                {
                                    AUTOLOCK(mutex);
                                    makeSplit(workItem.nodeIndex, winnerFeatureIndex, winnerCutPoint,
                                              static_cast<double>(localSplitCriterion(workItem.totalDataStatistics, sumWeights)),
                                              static_cast<int>(indexCnt));
                                    DAAL_ASSERT(!_nodes[workItem.nodeIndex].isLeaf());
                                    leftChild.nodeIndex = _nodes[workItem.nodeIndex].leftChildIndex();
                                    rightChild.nodeIndex = _nodes[workItem.nodeIndex].rightChildIndex();
                                }

                                // Partition.
                                size_t * splitIndexes = nullptr;
                                switch (context.featureTypesCache[winnerFeatureIndex])
                                {
                                case data_management::features::DAAL_CATEGORICAL:
                                    splitIndexes = partition<cpu>(&indexes[workItem.firstIndex], &indexes[workItem.lastIndex],
                                                                  [winnerFeatureIndex, winnerCutPoint, &context](size_t i) -> bool
                                                                  { return (context.dx[winnerFeatureIndex][i] == winnerCutPoint); });
                                    break;

                                case data_management::features::DAAL_ORDINAL:
                                case data_management::features::DAAL_CONTINUOUS:
                                    splitIndexes = partition<cpu>(&indexes[workItem.firstIndex], &indexes[workItem.lastIndex],
                                                                  [winnerFeatureIndex, winnerCutPoint, &context](size_t i) -> bool
                                                                  { return (context.dx[winnerFeatureIndex][i] < winnerCutPoint); });
                                    break;

                                default:
                                    DAAL_ASSERT(false);
                                    break;
                                }
                                DAAL_ASSERT(splitIndexes != nullptr);
                                DAAL_ASSERT(splitIndexes >= &indexes[workItem.firstIndex]);
                                DAAL_ASSERT(splitIndexes <= &indexes[workItem.lastIndex]);


                                leftChild.firstIndex = workItem.firstIndex;
                                leftChild.lastIndex = splitIndexes - indexes;
                                leftChild.depthLimit = workItem.depthLimit - 1;
                                leftChild.totalDataStatistics.swap(winnerDataStatistics);

                                rightChild.firstIndex = leftChild.lastIndex;
                                rightChild.lastIndex = workItem.lastIndex;
                                rightChild.depthLimit = leftChild.depthLimit;
                                rightChild.totalDataStatistics.swap(workItem.totalDataStatistics);
                                rightChild.totalDataStatistics -= leftChild.totalDataStatistics;

                                workStack.pop();
                                workStack.push(leftChild);
                                workStack.push(rightChild);
                            }
                        }
                    }
                }
            });

            delete[] workArray;
        }
    }

    template <typename SplitCriterion>
    bool findSplitInParallel(SplitCriterion & splitCriterion, const size_t * firstIndex, size_t indexCount,
                             const FeatureTypesCache & featureTypesCache, const typename SplitCriterion::DataStatistics & totalDataStatistics,
                             const IndependentVariableType * const * dx, const DependentVariableType * dy, const IndependentVariableType * dw, size_t featureCount,
                             FeatureIndex & winnerFeatureIndex, IndependentVariableType & winnerCutPoint,
                             typename SplitCriterion::ValueType & winnerSplitCriterionValue, size_t & winnerPointsAtLeft,
                             typename SplitCriterion::DataStatistics & winnerDataStatistics)
    {
        typedef daal::internal::Math<typename SplitCriterion::ValueType, cpu> SplitCriterionMath;
        typedef daal::services::internal::EpsilonVal<typename SplitCriterion::ValueType> SplitCriterionEpsilon;
        typedef typename SplitCriterion::DataStatistics DataStatistics;

        struct Item
        {
            IndependentVariable x;
            IndependentVariable w;
            DependentVariable y;
        };

        struct Local
        {
            FeatureIndex winnerFeatureIndex;
            IndependentVariableType winnerCutPoint;
            typename SplitCriterion::ValueType winnerSplitCriterionValue, splitCriterionValue;
            size_t winnerPointsAtLeft;
            DataStatistics winnerDataStatistics, bestCutPointDataStatistics, dataStatistics;
            bool winnerIsLeaf;
            SplitCriterion splitCriterion;

            Local(const SplitCriterion & criterion) : winnerIsLeaf(true), splitCriterion(criterion) {}
        };

        DAAL_ASSERT(firstIndex);

        daal::tls<Local *> localTLS([=, &splitCriterion]()-> Local *
        {
            Local * const ptr = new Local(splitCriterion);
            return ptr;
        } );

        const typename SplitCriterion::ValueType epsilon = SplitCriterionEpsilon::get();

        daal::threader_for(featureCount, featureCount, [=, &localTLS, &totalDataStatistics, &featureTypesCache, &dx, &dy, &dw](int featureIndex)
        {
            Local * const local = localTLS.local();

            Item * items = daal_alloc<Item>(indexCount);

            const size_t rowsPerBlock = 512;
            const size_t blockCount = (indexCount + rowsPerBlock - 1) / rowsPerBlock;

            for(size_t iBlock = 0; iBlock < blockCount; iBlock++)
            {
                const size_t first = iBlock * rowsPerBlock;
                const size_t last = min<cpu>(first + rowsPerBlock, indexCount);

                for (size_t i = first; i < last; ++i)
                {
                    items[i].x = dx[featureIndex][firstIndex[i]];
                    items[i].y = dy[firstIndex[i]];
                }
                if (dw)
                {
                    for (size_t i = first; i < last; ++i)
                    {
                        items[i].w = dw[firstIndex[i]];
                    }
                }
            }

            introSort<cpu>(items, &items[indexCount], [](const Item & v1, const Item & v2) -> bool
            {
                return v1.x < v2.x;
            });
            DAAL_ASSERT(isSorted<cpu>(items, &items[indexCount], [](const Item & v1, const Item & v2) -> bool
            {
                return v1.x < v2.x;
            }));

            Item * next = nullptr;
            const auto i = CutPointFinder<cpu, IndependentVariableType, SplitCriterion>::find(local->splitCriterion, items, &items[indexCount], local->dataStatistics,
                                                                     totalDataStatistics,
                                                                     featureTypesCache[featureIndex], next, local->splitCriterionValue,
                                                                     local->bestCutPointDataStatistics,
                                                                     [](const Item & v) -> IndependentVariableType { return v.x; },
                                                                     [](const Item & v) -> DependentVariable { return v.y; },
                                                                     [](const Item & v) -> IndependentVariableType { return v.w; },
                                                                     [](const Item & v1, const Item & v2) -> bool { return v1.x < v2.x; });

            if (i != &items[indexCount] && (local->winnerIsLeaf || local->splitCriterionValue < local->winnerSplitCriterionValue ||
                                            (SplitCriterionMath::sFabs(local->splitCriterionValue - local->winnerSplitCriterionValue) <= epsilon &&
                                             local->winnerFeatureIndex > featureIndex)))
            {
                local->winnerIsLeaf = false;
                local->winnerFeatureIndex = featureIndex;
                local->winnerSplitCriterionValue = local->splitCriterionValue;
                switch (featureTypesCache[featureIndex])
                {
                case data_management::features::DAAL_CATEGORICAL:
                    local->winnerCutPoint = i->x;
                    break;
                case data_management::features::DAAL_ORDINAL:
                    local->winnerCutPoint = next->x;
                    break;
                case data_management::features::DAAL_CONTINUOUS:
                    local->winnerCutPoint = (i->x + next->x) / 2;
                    break;
                default:
                    DAAL_ASSERT(false);
                    break;
                }
                local->winnerPointsAtLeft = next - items; // distance.
                local->winnerDataStatistics = local->bestCutPointDataStatistics;
            }

            daal_free(items);
            items = nullptr;
        } );

        bool winnerIsLeaf = true;
        localTLS.reduce([=, &winnerIsLeaf, &winnerSplitCriterionValue, &winnerFeatureIndex, &winnerCutPoint, &winnerPointsAtLeft,
                         &winnerDataStatistics](Local * v) -> void
        {
            if ((!v->winnerIsLeaf) && (winnerIsLeaf || v->winnerSplitCriterionValue < winnerSplitCriterionValue ||
                                       (SplitCriterionMath::sFabs(winnerSplitCriterionValue - v->winnerSplitCriterionValue) <= epsilon &&
                                        winnerFeatureIndex > v->winnerFeatureIndex)))
            {
                winnerIsLeaf = false;
                winnerFeatureIndex = v->winnerFeatureIndex;
                winnerSplitCriterionValue = v->winnerSplitCriterionValue;
                winnerCutPoint = v->winnerCutPoint;
                winnerPointsAtLeft = v->winnerPointsAtLeft;
                winnerDataStatistics.swap(v->winnerDataStatistics);
            }

            delete v;
            v = nullptr;
        } );
        return (!winnerIsLeaf);
    }

    template <typename SplitCriterion>
    bool findSplitInSerial(SplitCriterion & splitCriterion, const size_t * firstIndex, size_t indexCount,
                           const FeatureTypesCache & featureTypesCache, const typename SplitCriterion::DataStatistics & totalDataStatistics,
                           const IndependentVariableType * const * dx, const DependentVariableType * dy, const IndependentVariableType * dw, size_t featureCount,
                           FeatureIndex & winnerFeatureIndex, IndependentVariableType & winnerCutPoint,
                           typename SplitCriterion::ValueType & winnerSplitCriterionValue, size_t & winnerPointsAtLeft,
                           typename SplitCriterion::DataStatistics & winnerDataStatistics)
    {
        typedef daal::internal::Math<typename SplitCriterion::ValueType, cpu> SplitCriterionMath;
        typedef daal::services::internal::EpsilonVal<typename SplitCriterion::ValueType> SplitCriterionEpsilon;
        typedef typename SplitCriterion::DataStatistics DataStatistics;

        struct Item
        {
            IndependentVariable x;
            IndependentVariable w;
            DependentVariable y;
        };

        struct Local
        {
            FeatureIndex winnerFeatureIndex;
            IndependentVariableType winnerCutPoint;
            typename SplitCriterion::ValueType winnerSplitCriterionValue, splitCriterionValue;
            size_t winnerPointsAtLeft;
            DataStatistics winnerDataStatistics, bestCutPointDataStatistics, dataStatistics;
            bool winnerIsLeaf;
            SplitCriterion splitCriterion;

            Local(const SplitCriterion & criterion) : winnerIsLeaf(true), splitCriterion(criterion) {}
        };

        DAAL_ASSERT(firstIndex);

        daal::tls<Local *> localTLS([=, &splitCriterion]()-> Local *
        {
            Local * const ptr = new Local(splitCriterion);
            return ptr;
        } );

        const typename SplitCriterion::ValueType epsilon = SplitCriterionEpsilon::get();

        daal::threader_for(featureCount, featureCount, [=, &localTLS, &totalDataStatistics, &featureTypesCache, &dx, &dy, &dw](int featureIndex)
        {
            Local * const local = localTLS.local();

            Item * items = daal_alloc<Item>(indexCount);

            for (size_t i = 0; i < indexCount; ++i)
            {
                items[i].x = dx[featureIndex][firstIndex[i]];
                items[i].y = dy[firstIndex[i]];
            }
            if (dw)
            {
                for (size_t i = 0; i < indexCount; ++i)
                {
                    items[i].w = dw[firstIndex[i]];
                }
            }
            introSort<cpu>(items, &items[indexCount], [](const Item & v1, const Item & v2) -> bool
            {
                return v1.x < v2.x;
            });
            DAAL_ASSERT(isSorted<cpu>(items, &items[indexCount], [](const Item & v1, const Item & v2) -> bool
            {
                return v1.x < v2.x;
            }));

            Item * next = nullptr;
            const auto i = CutPointFinder<cpu, IndependentVariableType, SplitCriterion>::find(local->splitCriterion, items, &items[indexCount], local->dataStatistics,
                                                                     totalDataStatistics,
                                                                     featureTypesCache[featureIndex], next, local->splitCriterionValue,
                                                                     local->bestCutPointDataStatistics,
                                                                     [](const Item & v) -> IndependentVariableType { return v.x; },
                                                                     [](const Item & v) -> DependentVariable { return v.y; },
                                                                     [](const Item & v) -> IndependentVariableType { return v.w; },
                                                                     [](const Item & v1, const Item & v2) -> bool { return v1.x < v2.x; });

            if (i != &items[indexCount] && (local->winnerIsLeaf || local->splitCriterionValue < local->winnerSplitCriterionValue ||
                                            (SplitCriterionMath::sFabs(local->splitCriterionValue - local->winnerSplitCriterionValue) <= epsilon &&
                                             local->winnerFeatureIndex > featureIndex)))
            {
                local->winnerIsLeaf = false;
                local->winnerFeatureIndex = featureIndex;
                local->winnerSplitCriterionValue = local->splitCriterionValue;
                switch (featureTypesCache[featureIndex])
                {
                case data_management::features::DAAL_CATEGORICAL:
                    local->winnerCutPoint = i->x;
                    break;
                case data_management::features::DAAL_ORDINAL:
                    local->winnerCutPoint = next->x;
                    break;
                case data_management::features::DAAL_CONTINUOUS:
                    local->winnerCutPoint = (i->x + next->x) / 2;
                    break;
                default:
                    DAAL_ASSERT(false);
                    break;
                }
                local->winnerPointsAtLeft = next - items; // distance.
                local->winnerDataStatistics = local->bestCutPointDataStatistics;
            }

            daal_free(items);
            items = nullptr;
        } );

        bool winnerIsLeaf = true;
        localTLS.reduce([=, &winnerIsLeaf, &winnerSplitCriterionValue, &winnerFeatureIndex, &winnerCutPoint, &winnerPointsAtLeft,
                         &winnerDataStatistics](Local * v) -> void
        {
            if ((!v->winnerIsLeaf) && (winnerIsLeaf || v->winnerSplitCriterionValue < winnerSplitCriterionValue ||
                                       (SplitCriterionMath::sFabs(winnerSplitCriterionValue - v->winnerSplitCriterionValue) <= epsilon &&
                                        winnerFeatureIndex > v->winnerFeatureIndex)))
            {
                winnerIsLeaf = false;
                winnerFeatureIndex = v->winnerFeatureIndex;
                winnerSplitCriterionValue = v->winnerSplitCriterionValue;
                winnerCutPoint = v->winnerCutPoint;
                winnerPointsAtLeft = v->winnerPointsAtLeft;
                winnerDataStatistics.swap(v->winnerDataStatistics);
            }

            delete v;
            v = nullptr;
        } );
        return (!winnerIsLeaf);
    }

    template <typename Error, typename Data>
    Error internalREP(size_t nodeIndex, Data & data) const
    {
        if (_nodes[nodeIndex].isLeaf())
        {
            return data.error(nodeIndex, _nodes[nodeIndex].dependentVariable());
        }

        const Error subTreeError = internalREP<Error, Data>(_nodes[nodeIndex].leftChildIndex(), data)
                                   + internalREP<Error, Data>(_nodes[nodeIndex].rightChildIndex(), data);
        const Error leafError = data.error(nodeIndex);
        if (leafError <= subTreeError)
        { // Node must be pruned.
            data.prune(nodeIndex);
            return leafError;
        }
        else
        {
            return subTreeError;
        }
    }


private:
    TreeNodeType * _nodes;
    size_t _nodeCount;
    size_t _nodeCapacity;
};

template <CpuType cpu, typename DependentVariable>
class PruningData
{
public:
    typedef DependentVariable DependentVariableType;

    PruningData(size_t size) : _size(size),
                               _dependentVariables(daal_alloc<DependentVariableType>(size ? size : 1)),
                               _isPrunedValues(daal_alloc<bool>(size ? size : 1))
    {
        reset();
    }

    PruningData(const PruningData &) = delete;
    PruningData & operator= (const PruningData &) = delete;

    virtual ~PruningData()
    {
        daal_free(_isPrunedValues);
        daal_free(_dependentVariables);
        _isPrunedValues     = nullptr;
        _dependentVariables = nullptr;
    }

    size_t size() const { return _size; }

    bool isPruned(size_t index) const
    {
        DAAL_ASSERT(index < _size);
        return _isPrunedValues[index];
    }

    DependentVariableType dependentVariable(size_t index) const
    {
        DAAL_ASSERT(index < _size);
        return _dependentVariables[index];
    }

    virtual void putProbabilities(size_t index, double * probs, size_t numProbs) const {}

protected:
    void reset()
    {
        for (size_t i = 0; i < _size; ++i)
        {
            _dependentVariables[i] = 0;
            _isPrunedValues[i] = false;
        }
    }

    void prune(size_t index, DependentVariableType dependentVariable)
    {
        DAAL_ASSERT(index < _size);
        DAAL_ASSERT(!_isPrunedValues[index]);
        _isPrunedValues[index] = true;
        _dependentVariables[index] = dependentVariable;
    }

private:
    size_t _size;
    bool * _isPrunedValues;
    DependentVariableType * _dependentVariables;
};

template <CpuType cpu, typename IndependentVariable, typename DependentVariable>
size_t countNodes(size_t nodeIndex, const Tree<cpu, IndependentVariable, DependentVariable> & tree,
                  const PruningData<cpu, DependentVariable> & pruningData)
{
    if (tree[nodeIndex].isLeaf() || pruningData.isPruned(nodeIndex)) { return 1; }
    return 1 + countNodes<cpu>(tree[nodeIndex].leftChildIndex(), tree, pruningData)
             + countNodes<cpu>(tree[nodeIndex].rightChildIndex(), tree, pruningData);
}

} // namespace internal
} // namespace decision_tree
} // namespace algorithms
} // namespace daal

#endif
