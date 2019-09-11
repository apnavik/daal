/* file: DistributedPartialResultStep6.java */
/*******************************************************************************
* Copyright 2014-2019 Intel Corporation.
*
* This software and the related documents are Intel copyrighted  materials,  and
* your use of  them is  governed by the  express license  under which  they were
* provided to you (License).  Unless the License provides otherwise, you may not
* use, modify, copy, publish, distribute,  disclose or transmit this software or
* the related documents without Intel's prior written permission.
*
* This software and the related documents  are provided as  is,  with no express
* or implied  warranties,  other  than those  that are  expressly stated  in the
* License.
*******************************************************************************/

/**
 * @ingroup dbscan_distributed
 * @{
 */
package com.intel.daal.algorithms.dbscan;

import com.intel.daal.utils.*;
import com.intel.daal.data_management.data.NumericTable;
import com.intel.daal.data_management.data.DataCollection;
import com.intel.daal.data_management.data.Factory;
import com.intel.daal.services.DaalContext;

/**
 * <a name="DAAL-CLASS-ALGORITHMS__DBSCAN__DISTRIBUTEDPARTIALRESULTSTEP6"></a>
 * @brief Provides methods to access partial results obtained with the compute() method of the
 *        DBSCAN algorithm in the sixth step of the distributed processing mode
 */
public final class DistributedPartialResultStep6 extends com.intel.daal.algorithms.PartialResult {
    /** @private */
    static {
        LibUtils.loadLibrary();
    }

    /**
     * Constructs a partial result of the DBSCAN algorithm from the context
     * @param context Context to manage the memory in the native part of the partial result object
     */
    public DistributedPartialResultStep6(DaalContext context) {
        super(context);
        this.cObject = cNewDistributedPartialResultStep6();
    }

    DistributedPartialResultStep6(DaalContext context, long cObject) {
        super(context, cObject);
    }

    /**
     * Returns a partial result of the DBSCAN algorithm obtained in the sixth step of the distributed processing mode
     * @param  id   Identifier of the input object, @ref DistributedPartialResultStep6NumericTableId
     * @return      Partial result that corresponds to the given identifier
     */
    public NumericTable get(DistributedPartialResultStep6NumericTableId id) {
        if (id != DistributedPartialResultStep6NumericTableId.step6ClusterStructure &&
            id != DistributedPartialResultStep6NumericTableId.step6FinishedFlag &&
            id != DistributedPartialResultStep6NumericTableId.step6NClusters) {
            throw new IllegalArgumentException("id unsupported");
        }
        return (NumericTable)Factory.instance().createObject(getContext(), cGetNumericTable(getCObject(), id.getValue()));
    }

    /**
    * Sets a partial result of the DBSCAN algorithm obtained in the sixth step of the distributed processing mode
    * @param id     Identifier of the input object
    * @param value  Value of the input object
    */
    public void set(DistributedPartialResultStep6NumericTableId id, NumericTable value) {
        if (id != DistributedPartialResultStep6NumericTableId.step6ClusterStructure &&
            id != DistributedPartialResultStep6NumericTableId.step6FinishedFlag &&
            id != DistributedPartialResultStep6NumericTableId.step6NClusters) {
            throw new IllegalArgumentException("id unsupported");
        }
        cSetNumericTable(getCObject(), id.getValue(), value.getCObject());
    }

    /**
     * Returns a partial result of the DBSCAN algorithm obtained in the sixth step of the distributed processing mode
     * @param  id   Identifier of the input object, @ref DistributedPartialResultStep6CollectionId
     * @return      Partial result that corresponds to the given identifier
     */
    public DataCollection get(DistributedPartialResultStep6CollectionId id) {
        if (id != DistributedPartialResultStep6CollectionId.step6Queries) {
            throw new IllegalArgumentException("id unsupported");
        }
        return (DataCollection)Factory.instance().createObject(getContext(), cGetDataCollection(getCObject(), id.getValue()));
    }

    /**
    * Sets a partial result of the DBSCAN algorithm obtained in the sixth step of the distributed processing mode
    * @param id     Identifier of the input object
    * @param value  Value of the input object
    */
    public void set(DistributedPartialResultStep6CollectionId id, DataCollection value) {
        if (id != DistributedPartialResultStep6CollectionId.step6Queries) {
            throw new IllegalArgumentException("id unsupported");
        }
        cSetDataCollection(getCObject(), id.getValue(), value.getCObject());
    }

    private native long cNewDistributedPartialResultStep6();

    private native long cGetNumericTable(long cObject, int id);
    private native void cSetNumericTable(long cObject, int id, long cNumericTable);

    private native long cGetDataCollection(long cObject, int id);
    private native void cSetDataCollection(long cObject, int id, long cDataCollection);
}
/** @} */