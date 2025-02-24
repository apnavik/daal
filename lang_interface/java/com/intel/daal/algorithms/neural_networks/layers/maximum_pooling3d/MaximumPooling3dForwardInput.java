/* file: MaximumPooling3dForwardInput.java */
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
 * @defgroup maximum_pooling3d_forward Forward Three-dimensional Max Pooling Layer
 * @brief Contains classes for forward maximum 3D pooling layer
 * @ingroup maximum_pooling3d
 * @{
 */
package com.intel.daal.algorithms.neural_networks.layers.maximum_pooling3d;

import com.intel.daal.utils.*;
import com.intel.daal.services.DaalContext;

/**
 * <a name="DAAL-CLASS-ALGORITHMS__NEURAL_NETWORKS__LAYERS__MAXIMUM_POOLING3D__MAXIMUMPOOLING3DFORWARDINPUT"></a>
 * @brief %Input object for the forward three-dimensional maximum pooling layer
 */
public class MaximumPooling3dForwardInput extends com.intel.daal.algorithms.neural_networks.layers.pooling3d.Pooling3dForwardInput {
    /** @private */
    static {
        LibUtils.loadLibrary();
    }

    public MaximumPooling3dForwardInput(DaalContext context, long cObject) {
        super(context, cObject);
    }
}
/** @} */
