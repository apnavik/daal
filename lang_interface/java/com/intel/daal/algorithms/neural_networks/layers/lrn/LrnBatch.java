/* file: LrnBatch.java */
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
 * @defgroup lrn Local Response Normalization Layer
 * @brief Contains classes for local response normalization layer
 * @ingroup layers
 * @{
 */
/**
 * @brief Contains classes of the local response normalization layer
 */
package com.intel.daal.algorithms.neural_networks.layers.lrn;

import com.intel.daal.utils.*;
import com.intel.daal.algorithms.neural_networks.layers.ForwardLayer;
import com.intel.daal.algorithms.neural_networks.layers.BackwardLayer;
import com.intel.daal.algorithms.Precision;
import com.intel.daal.algorithms.ComputeMode;
import com.intel.daal.services.DaalContext;

/**
 * <a name="DAAL-CLASS-ALGORITHMS__NEURAL_NETWORKS__LAYERS__LRN__LRNBATCH"></a>
 * @brief Provides methods for the local response normalization layer in the batch processing mode
 * <!-- \n<a href="DAAL-REF-LRNFORWARD-ALGORITHM">Forward lrn layer description and usage models</a> -->
 * <!-- \n<a href="DAAL-REF-LRNBACKWARD-ALGORITHM">Backward lrn layer description and usage models</a> -->
 *
 * @par References
 *      - @ref LrnForwardBatch class
 *      - @ref LrnBackwardBatch class
 */
public class LrnBatch extends com.intel.daal.algorithms.neural_networks.layers.LayerIface {
    public    LrnMethod        method;        /*!< Computation method for the layer */
    public    LrnParameter     parameter;   /*!< lrn layer parameters */
    protected Precision     prec;        /*!< Data type to use in intermediate computations for the layer */

    /** @private */
    static {
        LibUtils.loadLibrary();
    }

    /**
     * Constructs the local response normalization layer
     * @param context    Context to manage the local response normalization layer
     * @param cls        Data type to use in intermediate computations for the layer, Double.class or Float.class
     * @param method     The layer computation method, @ref LrnMethod
     */
    public LrnBatch(DaalContext context, Class<? extends Number> cls, LrnMethod method) {
        super(context);

        this.method = method;

        if (method != LrnMethod.defaultDense) {
            throw new IllegalArgumentException("method unsupported");
        }
        if (cls != Double.class && cls != Float.class) {
            throw new IllegalArgumentException("type unsupported");
        }

        if (cls == Double.class) {
            prec = Precision.doublePrecision;
        }
        else {
            prec = Precision.singlePrecision;
        }

        this.cObject = cInit(prec.getValue(), method.getValue());
        parameter = new LrnParameter(context, cInitParameter(cObject, prec.getValue(), method.getValue()));

        forwardLayer = (ForwardLayer)(new LrnForwardBatch(context, cls, method, cGetForwardLayer(cObject, prec.getValue(), method.getValue())));
        backwardLayer = (BackwardLayer)(new LrnBackwardBatch(context, cls, method, cGetBackwardLayer(cObject, prec.getValue(), method.getValue())));
    }

    private native long cInit(int prec, int method);
    private native long cInitParameter(long cAlgorithm, int prec, int method);
    private native long cGetForwardLayer(long cAlgorithm, int prec, int method);
    private native long cGetBackwardLayer(long cAlgorithm, int prec, int method);
}
/** @} */
