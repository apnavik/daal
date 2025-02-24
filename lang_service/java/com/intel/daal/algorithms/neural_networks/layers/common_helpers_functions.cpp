/* file: common_helpers_functions.cpp */
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

#include "common_helpers_functions.h"

namespace daal
{
using namespace daal::services;

jlongArray getJavaLongArrayFromSizeTCollection(JNIEnv *env, const Collection<size_t> &dims)
{
    size_t size = dims.size();
    jlongArray jDims = env->NewLongArray(size);

    for(size_t i = 0; i < size; i++)
    {
        jlong val = (jlong)dims[i];
        env->SetLongArrayRegion(jDims, i, 1, &val);
    }
    return jDims;
}
}
