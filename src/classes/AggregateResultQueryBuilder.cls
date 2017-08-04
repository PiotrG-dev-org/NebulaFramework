
/**
*
* @group Query Builder
* @group-content /ApexDocContent/QueryBuilder.html
*
* @description TODO A builder class that generates dynamic queries & returns a list of AggregateResult
*/

//TODO add header
public class AggregateResultQueryBuilder implements IAggregateResultQueryBuilder {//{} //extends QueryBuilder implements IAggregateResultQueryBuilder {

    private Schema.SObjectType sobjectType;
    private List<String> queryFields;
    private List<String> aggregateFunctionList;
    private List<String> groupByList;
    private List<String> groupByRollupList;

    public AggregateResultQueryBuilder() {
        this.aggregateFunctionList = new List<String>();
        this.groupByList           = new List<String>();
    }

    // Setter methods
    public IAggregateResultQueryBuilder setSObjectType(Schema.SObjectType sobjectType) {
        this.sobjectType = sobjectType;
        return this;
    }

    public IAggregateResultQueryBuilder avg(Schema.SObjectField numericSObjectField) {
        return buildAggregateFunction('AVG', numericSObjectField);
    }

    public IAggregateResultQueryBuilder count_distinct(Schema.SObjectField sobjectField) {
        return buildAggregateFunction('COUNT_DISTINCT', sobjectField);
    }

    public IAggregateResultQueryBuilder count() {
        // COUNT() works differently from the other functions
        // It doesn't use a field as a parameter, so it builds its own string here
        // instead of using the buildAggregateFunction method
        this.aggregateFunctionList.add('COUNT() COUNT');
        return this;
    }

    public IAggregateResultQueryBuilder count(Schema.SObjectField sobjectField) {
        return buildAggregateFunction('COUNT', sobjectField);
    }

    public IAggregateResultQueryBuilder max(Schema.SObjectField sobjectField) {
        return buildAggregateFunction('MAX', sobjectField);
    }

    public IAggregateResultQueryBuilder min(Schema.SObjectField sobjectField) {
        return buildAggregateFunction('MIN', sobjectField);
    }

    public IAggregateResultQueryBuilder sum(Schema.SObjectField numericSObjectField) {
        return buildAggregateFunction('SUM', numericSObjectField);
    }

    public IAggregateResultQueryBuilder groupBy(Schema.FieldSet fieldSet) {
        // TODO
        for(Schema.FieldSetMember field : fieldSet.getFields()) this.groupByList.add(field.getFieldPath().toLowerCase());
        return this;
    }

    public IAggregateResultQueryBuilder groupBy(Schema.SObjectField groupByField) {
        this.groupByList.add(groupByField.getDescribe().getName());
        return this;
    }

    public IAggregateResultQueryBuilder groupBy(List<Schema.SObjectField> groupByRollupFields) {
        for(Schema.SobjectField field : groupByRollupFields) groupByRollupList.add(field.getDescribe().getName());
        return this;
    }

    public List<AggregateResult> getQueryResults() {
        return new List<AggregateResult>();
    }

    public String getQueryString() { // TODO make it inherit & override from IQueryBuilder
        String queryString = 'SELECT ' + this.getGroupByFieldString() + this.getAggregateFunctionString()
            + '\nFROM ' + this.sobjectType.getDescribe().getName()
            + this.getWhereClauseString()
            + '\nGROUP BY ' + getGroupByFieldString();
            //+ this.getOrderByString()
            //+ this.getLimitCountString()
            //+ this.getForUpdateString();

        return queryString;
    }

    private String getGroupByFieldString() {// TODO - SObjectQueryBuilder?? Aggregate needs to include aggregate functions (avg, sum, etc) in the query field string

        this.groupByList.sort();
        return String.join(this.groupByList, ', ');
    }

    private String getAggregateFunctionString() {
        this.aggregateFunctionList.sort();
        //TODO make better - adds a comma when needed for 'Type, COUNT_DISTINCT(OwnerId)'
        String extraDelimiter = getGroupByFieldString() == null ? '' : ', ';
        return extraDelimiter + String.join(this.aggregateFunctionList, ', ');
    }

    private String getWhereClauseString() {
        //return this.whereClauseList.isEmpty() ? '' : '\nWHERE ' + String.join(this.whereClauseList, '\nAND ');
        return '';
    }

/**
 * [fieldName description]
 * @type {[type]}
 */
    private IAggregateResultQueryBuilder buildAggregateFunction(String functionName, Schema.SObjectField sobjectField) {
        String fieldName = sobjectField.getDescribe().getName();
        // Alias: MIN(Schema.Lead.MyField__c) is auto-aliased to MIN_MyField__c
        this.aggregateFunctionList.add(functionName + '(' + fieldName + ') ' + functionName + '_' +fieldName);
        return this;
    }

}