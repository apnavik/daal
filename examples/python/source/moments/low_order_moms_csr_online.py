# file: low_order_moms_csr_online.py
#===============================================================================
# Copyright 2014-2019 Intel Corporation.
#
# This software and the related documents are Intel copyrighted  materials,  and
# your use of  them is  governed by the  express license  under which  they were
# provided to you (License).  Unless the License provides otherwise, you may not
# use, modify, copy, publish, distribute,  disclose or transmit this software or
# the related documents without Intel's prior written permission.
#
# This software and the related documents  are provided as  is,  with no express
# or implied  warranties,  other  than those  that are  expressly stated  in the
# License.
#===============================================================================

## <a name="DAAL-EXAMPLE-PY-LOW_ORDER_MOMENTS_CSR_ONLINE"></a>
## \example low_order_moms_csr_online.py

import os
import sys

from daal.algorithms import low_order_moments

utils_folder = os.path.realpath(os.path.abspath(os.path.dirname(os.path.dirname(__file__))))
if utils_folder not in sys.path:
    sys.path.insert(0, utils_folder)
from utils import printNumericTable, createSparseTable

DAAL_PREFIX = os.path.join('..', 'data')

# Input data set parameters
nBlocks = 4

datasetFileNames = [
    os.path.join(DAAL_PREFIX, 'online', 'covcormoments_csr_1.csv'),
    os.path.join(DAAL_PREFIX, 'online', 'covcormoments_csr_2.csv'),
    os.path.join(DAAL_PREFIX, 'online', 'covcormoments_csr_3.csv'),
    os.path.join(DAAL_PREFIX, 'online', 'covcormoments_csr_4.csv')
]


def printResults(res):
    printNumericTable(res.get(low_order_moments.minimum),              "Minimum:")
    printNumericTable(res.get(low_order_moments.maximum),              "Maximum:")
    printNumericTable(res.get(low_order_moments.sum),                  "Sum:")
    printNumericTable(res.get(low_order_moments.sumSquares),           "Sum of squares:")
    printNumericTable(res.get(low_order_moments.sumSquaresCentered),   "Sum of squared difference from the means:")
    printNumericTable(res.get(low_order_moments.mean),                 "Mean:")
    printNumericTable(res.get(low_order_moments.secondOrderRawMoment), "Second order raw moment:")
    printNumericTable(res.get(low_order_moments.variance),             "Variance:")
    printNumericTable(res.get(low_order_moments.standardDeviation),    "Standard deviation:")
    printNumericTable(res.get(low_order_moments.variation),            "Variation:")

if __name__ == "__main__":

    # Create algorithm objects for low order moments computing in online mode using default method
    algorithm = low_order_moments.Online()

    for i in range(nBlocks):
        dataTable = createSparseTable(datasetFileNames[i])

        # Set input arguments of the algorithm
        algorithm.input.set(low_order_moments.data, dataTable)

        # Compute partial low order moments estimates
        algorithm.compute()

    # Finalize online result and get computed low order moments
    res = algorithm.finalizeCompute()

    printResults(res)