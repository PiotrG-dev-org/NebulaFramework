/*************************************************************************************************
* This file is part of the Nebula Framework project, released under the MIT License.             *
* See LICENSE file or go to https://github.com/jongpie/NebulaFramework for full license details. *
*************************************************************************************************/
public interface IQueryFilter {

    Object getProvidedValue();
    Schema.SObjectField getSObjectField();
    String getValue();

}