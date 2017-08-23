/* file: TrainingMethod.java */
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

/**
 * @defgroup logitboost_training Training
 * @brief Contains classes for LogitBoost models training
 * @ingroup logitboost
 * @{
 */
package com.intel.daal.algorithms.logitboost.training;

/**
 * <a name="DAAL-CLASS-ALGORITHMS__LOGITBOOST__TRAINING__TRAININGMETHOD"></a>
 * @brief Available methods for training LogitBoost models
 */
public final class TrainingMethod {

    private int _value;

    public TrainingMethod(int value) {
        _value = value;
    }

    public int getValue() {
        return _value;
    }

    private static final int Friedman = 0;

    /** Default method proposed by Friedman et al. */
    public static final TrainingMethod friedman = new TrainingMethod(Friedman);
}
/** @} */