/* file: binary_confusion_matrix_types.h */
/*******************************************************************************
* Copyright 2014-2017 Intel Corporation
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
//  Declaration of data types for computing the binary confusion matrix.
//--
*/

#ifndef __BINARY_CONFUSION_MATRIX_TYPES_H__
#define __BINARY_CONFUSION_MATRIX_TYPES_H__

#include "algorithms/algorithm.h"
#include "data_management/data/homogen_numeric_table.h"

namespace daal
{
namespace algorithms
{
namespace classifier
{
/**
 * @defgroup quality_metric Quality Metrics
 * \copydoc daal::algorithms::classifier::quality_metric
 * @ingroup analysis
 */
/**
 * \brief Contains classes for checking the quality of the classification algorithms
 */
namespace quality_metric
{
/**
 * @defgroup quality_metric_binary Quality Metrics for Binary Classification Algorithms
 * \copydoc daal::algorithms::classifier::quality_metric::binary_confusion_matrix
 * @ingroup quality_metric
 * @{
 */
/**
 * \brief Contains classes for computing the binary confusion matrix
 */
namespace binary_confusion_matrix
{
/**
 * <a name="DAAL-ENUM-ALGORITHMS__CLASSIFIER__QUALITY_METRIC__BINARY_CONFUSION_MATRIX__METHOD"></a>
 * Available methods for computing the binary confusion matrix
 */
enum Method
{
    defaultDense = 0    /*!< Default method */
};

/**
 * <a name="DAAL-ENUM-ALGORITHMS__CLASSIFIER__QUALITY_METRIC__BINARY_CONFUSION_MATRIX__INPUTID"></a>
 * Available identifiers of input objects for the binary confusion matrix algorithm
 */
enum InputId
{
    predictedLabels   = 0,     /*!< Labels computed in the prediction stage of the classification algorithm */
    groundTruthLabels = 1      /*!< Expected labels */
};

/**
 * <a name="DAAL-ENUM-ALGORITHMS__CLASSIFIER__QUALITY_METRIC__BINARY_CONFUSION_MATRIX__RESULTID"></a>
 * Available identifiers of results of the binary confusion matrix algorithm
 */
enum ResultId
{
    confusionMatrix = 0,        /*!< Binary confusion matrix */
    binaryMetrics   = 1,        /*!< Table that contains quality metrics (that is, precision, recall, etc.) for binary classifiers */
};

/**
 * <a name="DAAL-ENUM-ALGORITHMS__CLASSIFIER__QUALITY_METRIC__BINARY_CONFUSION_MATRIX__BINARYMETRICSID"></a>
 * Available values stored in a numeric table corresponding to the ResultId::binaryMatrix index
 */
enum BinaryMetricsId
{
    accuracy    = 0,            /*!< Accuracy */
    precision   = 1,            /*!< Precision */
    recall      = 2,            /*!< Recall */
    fscore      = 3,            /*!< F-score */
    specificity = 4,            /*!< Specificity */
    AUC         = 5             /*!< Area under the curve (AUC). Ability to avoid false classification */
};

/**
 * \brief Contains version 1.0 of the Intel(R) Data Analytics Acceleration Library (Intel(R) DAAL) interface.
 */
namespace interface1
{
/**
 * <a name="DAAL-STRUCT-ALGORITHMS__CLASSIFIER__QUALITY_METRIC__BINARY_CONFUSION_MATRIX__PARAMETER"></a>
 * \brief Parameters for the binary confusion matrix compute() method
 *
 * \snippet classifier/binary_confusion_matrix_types.h Parameter source code
 */
/* [Parameter source code] */
struct DAAL_EXPORT Parameter : public daal::algorithms::Parameter
{
    Parameter(double beta = 1.0);
    virtual ~Parameter() {}

    double beta;            /*!< Parameter of the F-score */

    void check() const DAAL_C11_OVERRIDE;
};
/* [Parameter source code] */

/**
 * <a name="DAAL-CLASS-ALGORITHMS__CLASSIFIER__QUALITY_METRIC__BINARY_CONFUSION_MATRIX__INPUT"></a>
 * \brief Base class for input objects of the binary confusion matrix algorithm
 */
class DAAL_EXPORT Input : public daal::algorithms::Input
{
public:
    Input();

    virtual ~Input() {}

    /**
     * Returns an input object of the quality metric
     * \param[in] id   Identifier of the input object
     * \return         %Input object that corresponds to the given identifier
     */
    data_management::NumericTablePtr get(InputId id) const;

    /**
     * Sets an input object of the quality metric
     * \param[in] id    Identifier of the input object
     * \param[in] value Pointer to the input object
     */
    void set(InputId id, const data_management::NumericTablePtr &value);

    /**
     * Checks the correctness of an input object
     * \param[in] parameter Pointer to the algorithm parameters
     * \param[in] method    Computation method
     */
    void check(const daal::algorithms::Parameter *parameter, int method) const DAAL_C11_OVERRIDE;
};

/**
 * <a name="DAAL-CLASS-ALGORITHMS__CLASSIFIER__QUALITY_METRIC__BINARY_CONFUSION_MATRIX__RESULT"></a>
 * \brief Results obtained with the compute() method of the binary confusion matrix algorithm
 *        in the batch processing mode
 */
class DAAL_EXPORT Result : public daal::algorithms::Result
{
public:
    DECLARE_SERIALIZABLE();
    Result();
    virtual ~Result() {}

    /**
     * Returns the quality metric of the classification algorithm
     * \param[in] id    Identifier of the result, \ref ResultId
     * \return          Quality metric of the classification algorithm
     */
    data_management::NumericTablePtr get(ResultId id) const;

    /**
     * Sets the result of the binary confusion matrix algorithm
     * \param[in] id    Identifier of the result, \ref ResultId
     * \param[in] value Pointer to the result
     */
    void set(ResultId id, const data_management::NumericTablePtr &value);

    /**
     * Allocates memory for storing results of the quality metric algorithm
     * \param[in] input     Pointer to the input objects structure
     * \param[in] parameter Pointer to the parameter structure
     * \param[in] method    Computation method of the algorithm
     */
    template<typename algorithmFPType>
    DAAL_EXPORT void allocate(const daal::algorithms::Input *input, const daal::algorithms::Parameter *parameter, const int method);

    /**
     * Checks the correctness of the Result object
     * \param[in] input     Pointer to the structure of the input objects
     * \param[in] parameter Pointer to the algorithm parameters
     * \param[in] method    Computation method
     */
    void check(const daal::algorithms::Input *input, const daal::algorithms::Parameter *parameter, int method) const DAAL_C11_OVERRIDE;

protected:
    /** \private */
    template<typename Archive, bool onDeserialize>
    void serialImpl(Archive *arch)
    {
        daal::algorithms::Result::serialImpl<Archive, onDeserialize>(arch);
    }

    void serializeImpl(data_management::InputDataArchive  *arch) DAAL_C11_OVERRIDE
    {serialImpl<data_management::InputDataArchive, false>(arch);}


    void deserializeImpl(data_management::OutputDataArchive *arch) DAAL_C11_OVERRIDE
    {serialImpl<data_management::OutputDataArchive, true>(arch);}
};
} // namespace interface1
using interface1::Parameter;
using interface1::Input;
using interface1::Result;

}
/** @} */
} // namespace daal::algorithms::classifier::quality_metric
} // namespace daal::algorithms::classifier
} // namespace daal::algorithms
} // namespace daal
#endif