/* file: SpatialMaximumPooling2dLayerDataNumericTableId.java */
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
 * @ingroup spatial_maximum_pooling2d
 * @{
 */
package com.intel.daal.algorithms.neural_networks.layers.spatial_maximum_pooling2d;

import java.lang.annotation.Native;

import com.intel.daal.utils.*;
/**
 * <a name="DAAL-CLASS-ALGORITHMS__NEURAL_NETWORKS__LAYERS__SPATIAL_MAXIMUM_POOLING2D__SPATIALMAXIMUMPOOLING2DLAYERDATANUMERICTABLEID"></a>
 * \brief Identifiers of input objects for the backward two-dimensional spatial maximum pooling layer and
 *        results for the forward two-dimensional spatial maximum pooling layer
 */
public final class SpatialMaximumPooling2dLayerDataNumericTableId {
    /** @private */
    static {
        LibUtils.loadLibrary();
    }

    private int _value;

    /**
     * Constructs the input object identifier using the provided value
     * @param value     Value corresponding to the input object identifier
     */
    public SpatialMaximumPooling2dLayerDataNumericTableId(int value) {
        _value = value;
    }

    /**
     * Returns the value corresponding to the input object identifier
     * @return Value corresponding to the input object identifier
     */
    public int getValue() {
        return _value;
    }

    @Native private static final int auxInputDimensionsId = 1;

    public static final SpatialMaximumPooling2dLayerDataNumericTableId auxInputDimensions = new SpatialMaximumPooling2dLayerDataNumericTableId(
        auxInputDimensionsId);    /*!< Numeric table of size 1 x p that contains the sizes
                                       of the dimensions of the input data tensor */
}
/** @} */
