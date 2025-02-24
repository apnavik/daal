/* file: StochasticPooling2dBatch.java */
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
 * @defgroup stochastic_pooling2d Two-dimensional Stochastic Pooling Layer
 * @brief Contains classes for stochastic two-dimensional (2D) pooling layer
 * @ingroup pooling2d
 * @{
 */
/**
 * @brief Contains classes of the two-dimensional (2D) stochastic pooling layer
 */
package com.intel.daal.algorithms.neural_networks.layers.stochastic_pooling2d;

import com.intel.daal.utils.*;
import com.intel.daal.algorithms.neural_networks.layers.ForwardLayer;
import com.intel.daal.algorithms.neural_networks.layers.BackwardLayer;
import com.intel.daal.algorithms.Precision;
import com.intel.daal.algorithms.ComputeMode;
import com.intel.daal.services.DaalContext;

/**
 * <a name="DAAL-CLASS-ALGORITHMS__NEURAL_NETWORKS__LAYERS__STOCHASTIC_POOLING2D__STOCHASTICPOOLING2DBATCH"></a>
 * @brief Provides methods for the two-dimensional stochastic pooling layer in the batch processing mode
 * <!-- \n<a href="DAAL-REF-STOCHASTICPOOLING2DFORWARD-ALGORITHM">Forward two-dimensional stochastic pooling layer description and usage models</a> -->
 * <!-- \n<a href="DAAL-REF-STOCHASTICPOOLING2DBACKWARD-ALGORITHM">Backward two-dimensional stochastic pooling layer description and usage models</a> -->
 *
 * @par References
 *      - @ref StochasticPooling2dForwardBatch class
 *      - @ref StochasticPooling2dBackwardBatch class
 */
public class StochasticPooling2dBatch extends com.intel.daal.algorithms.neural_networks.layers.LayerIface {
    public    StochasticPooling2dMethod        method;      /*!< Computation method for the layer */
    public    StochasticPooling2dParameter     parameter;   /*!< Pooling layer parameters */
    protected Precision     prec;        /*!< Data type to use in intermediate computations for the layer */

    /** @private */
    static {
        LibUtils.loadLibrary();
    }

    /**
     * Constructs the two-dimensional stochastic pooling layer
     * @param context    Context to manage the two-dimensional stochastic pooling layer
     * @param cls        Data type to use in intermediate computations for the layer, Double.class or Float.class
     * @param method     The layer computation method, @ref StochasticPooling2dMethod
     * @param nDim       Number of dimensions in input data
     */
    public StochasticPooling2dBatch(DaalContext context, Class<? extends Number> cls, StochasticPooling2dMethod method, long nDim) {
        super(context);

        this.method = method;

        if (method != StochasticPooling2dMethod.defaultDense) {
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

        this.cObject = cInit(prec.getValue(), method.getValue(), nDim);
        parameter = new StochasticPooling2dParameter(context, cInitParameter(cObject, prec.getValue(), method.getValue()));

        forwardLayer = (ForwardLayer)(new StochasticPooling2dForwardBatch(context, cls, method, cGetForwardLayer(cObject, prec.getValue(), method.getValue()), nDim));
        backwardLayer = (BackwardLayer)(new StochasticPooling2dBackwardBatch(context, cls, method, cGetBackwardLayer(cObject, prec.getValue(),
                                                                                                  method.getValue()), nDim));
    }

    private native long cInit(int prec, int method, long nDim);
    private native long cInitParameter(long cAlgorithm, int prec, int method);
    private native long cGetForwardLayer(long cAlgorithm, int prec, int method);
    private native long cGetBackwardLayer(long cAlgorithm, int prec, int method);
}
/** @} */
