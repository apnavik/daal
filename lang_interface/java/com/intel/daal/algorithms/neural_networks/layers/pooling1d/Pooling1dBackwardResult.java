/* file: Pooling1dBackwardResult.java */
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

/**
 * @ingroup pooling1d_backward
 * @{
 */
package com.intel.daal.algorithms.neural_networks.layers.pooling1d;

import com.intel.daal.utils.*;
import com.intel.daal.services.DaalContext;

/**
 * <a name="DAAL-CLASS-ALGORITHMS__NEURAL_NETWORKS__LAYERS__POOLING1D__POOLING1DBACKWARDRESULT"></a>
 * @brief Provides methods to access results obtained with the compute() method of the backward one-dimensional pooling layer
 */
public class Pooling1dBackwardResult extends com.intel.daal.algorithms.neural_networks.layers.BackwardResult {
    /** @private */
    static {
        LibUtils.loadLibrary();
    }

    /**
    * Constructs the backward one-dimensional pooling layer
    * @param context   Context to manage the backward one-dimensional pooling layer
    */
    public Pooling1dBackwardResult(DaalContext context) {
        super(context);
    }

    public Pooling1dBackwardResult(DaalContext context, long cObject) {
        super(context, cObject);
    }
}
/** @} */
