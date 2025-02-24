/* file: DropoutForwardBatch.java */
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
 * @defgroup dropout_forward_batch Batch
 * @ingroup dropout_forward
 * @{
 */
package com.intel.daal.algorithms.neural_networks.layers.dropout;

import com.intel.daal.utils.*;
import com.intel.daal.algorithms.Precision;
import com.intel.daal.algorithms.ComputeMode;
import com.intel.daal.algorithms.AnalysisBatch;
import com.intel.daal.services.DaalContext;

/**
 * <a name="DAAL-CLASS-ALGORITHMS__NEURAL_NETWORKS__LAYERS__DROPOUT__DROPOUTFORWARDBATCH"></a>
 * \brief Class that computes the results of the forward dropout layer in the batch processing mode
 * <!-- \n<a href="DAAL-REF-DROPOUTFORWARD">Forward dropout layer description and usage models</a> -->
 *
 * \par References
 *      - @ref DropoutLayerDataId class
 */
public class DropoutForwardBatch extends com.intel.daal.algorithms.neural_networks.layers.ForwardLayer {
    public  DropoutForwardInput input;     /*!< %Input data */
    public  DropoutMethod       method;    /*!< Computation method for the layer */
    public  DropoutParameter    parameter; /*!< DropoutParameters of the layer */
    private Precision    prec;      /*!< Data type to use in intermediate computations for the layer */

    /** @private */
    static {
        LibUtils.loadLibrary();
    }

    /**
     * Constructs the forward dropout layer by copying input objects of another forward dropout layer
     * @param context    Context to manage the forward dropout layer
     * @param other      A forward dropout layer to be used as the source to
     *                  initialize the input objects of the forward dropout layer
     */
    public DropoutForwardBatch(DaalContext context, DropoutForwardBatch other) {
        super(context);
        this.method = other.method;
        prec = other.prec;

        this.cObject = cClone(other.cObject, prec.getValue(), method.getValue());
        input = new DropoutForwardInput(context, cGetInput(cObject, prec.getValue(), method.getValue()));
        parameter = new DropoutParameter(context, cInitParameter(cObject, prec.getValue(), method.getValue()));
    }

    /**
     * Constructs the forward dropout layer
     * @param context    Context to manage the layer
     * @param cls        Data type to use in intermediate computations for the layer, Double.class or Float.class
     * @param method     The layer computation method, @ref DropoutMethod
     */
    public DropoutForwardBatch(DaalContext context, Class<? extends Number> cls, DropoutMethod method) {
        super(context);

        this.method = method;

        if (method != DropoutMethod.defaultDense) {
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
        input = new DropoutForwardInput(context, cGetInput(cObject, prec.getValue(), method.getValue()));
        parameter = new DropoutParameter(context, cInitParameter(cObject, prec.getValue(), method.getValue()));
    }

    DropoutForwardBatch(DaalContext context, Class<? extends Number> cls, DropoutMethod method, long cObject) {
        super(context);

        this.method = method;

        if (method != DropoutMethod.defaultDense) {
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

        this.cObject = cObject;
        input = new DropoutForwardInput(context, cGetInput(cObject, prec.getValue(), method.getValue()));
        parameter = new DropoutParameter(context, cInitParameter(cObject, prec.getValue(), method.getValue()));
    }

    /**
     * Computes the result of the forward dropout layer
     * @return  Forward dropout layer result
     */
    @Override
    public DropoutForwardResult compute() {
        super.compute();
        DropoutForwardResult result = new DropoutForwardResult(getContext(), cGetResult(cObject, prec.getValue(), method.getValue()));
        return result;
    }

    /**
     * Registers user-allocated memory to store the result of the forward dropout layer
     * @param result    Structure to store the result of the forward dropout layer
     */
    public void setResult(DropoutForwardResult result) {
        cSetResult(cObject, prec.getValue(), method.getValue(), result.getCObject());
    }

    /**
     * Returns the structure that contains result of the forward layer
     * @return Structure that contains result of the forward layer
     */
    @Override
    public DropoutForwardResult getLayerResult() {
        return new DropoutForwardResult(getContext(), cGetResult(cObject, prec.getValue(), method.getValue()));
    }

    /**
     * Returns the structure that contains input object of the forward layer
     * @return Structure that contains input object of the forward layer
     */
    @Override
    public DropoutForwardInput getLayerInput() {
        return input;
    }

    /**
     * Returns the structure that contains parameters of the forward layer
     * @return Structure that contains parameters of the forward layer
     */
    @Override
    public DropoutParameter getLayerParameter() {
        return parameter;
    }

    /**
     * Returns the newly allocated forward dropout layer
     * with a copy of input objects of this forward dropout layer
     * @param context    Context to manage the layer
     *
     * @return The newly allocated forward dropout layer
     */
    @Override
    public DropoutForwardBatch clone(DaalContext context) {
        return new DropoutForwardBatch(context, this);
    }

    private native long cInit(int prec, int method);
    private native long cInitParameter(long cAlgorithm, int prec, int method);
    private native long cGetInput(long cAlgorithm, int prec, int method);
    private native long cGetResult(long cAlgorithm, int prec, int method);
    private native void cSetResult(long cAlgorithm, int prec, int method, long cObject);
    private native long cClone(long algAddr, int prec, int method);
}
/** @} */
