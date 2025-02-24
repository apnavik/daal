/* file: AveragePooling2dForwardInput.java */
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
 * @defgroup average_pooling2d_forward Forward Two-dimensional Average Pooling Layer
 * @brief Contains classes for forward average 2D pooling layer
 * @ingroup average_pooling2d
 * @{
 */
package com.intel.daal.algorithms.neural_networks.layers.average_pooling2d;

import com.intel.daal.utils.*;
import com.intel.daal.services.DaalContext;

/**
 * <a name="DAAL-CLASS-ALGORITHMS__NEURAL_NETWORKS__LAYERS__AVERAGE_POOLING2D__AVERAGEPOOLING2DFORWARDINPUT"></a>
 * @brief %Input object for the forward two-dimensional average pooling layer
 */
public class AveragePooling2dForwardInput extends com.intel.daal.algorithms.neural_networks.layers.pooling2d.Pooling2dForwardInput {
    /** @private */
    static {
        LibUtils.loadLibrary();
    }

    public AveragePooling2dForwardInput(DaalContext context, long cObject) {
        super(context, cObject);
    }
}
/** @} */
