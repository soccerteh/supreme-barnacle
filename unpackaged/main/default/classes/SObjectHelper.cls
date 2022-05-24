public with sharing class SObjectHelper {
    private SObject record;
    private SObject oldRecord;
    
    
    /**
    * @description Default constructor for SObjectHelper class.
    * @author NickHolly | 03-16-2022 
    **/
    @SuppressWarnings('PMD.EmptyStatementBlock')
    //Default constructor
    public SObjectHelper() {

    }
    
    /**
    * @description 
    * @author NickHolly | 03-16-2022 
    * @param record 
    * @return SObjectHelper 
    **/
    public SObjectHelper setCurrentValues(SObject record) {
        this.record = record;
        return this;
    }

    @TestVisible
    private SObject getCurrentValues() {
        return record;
    }

    @TestVisible
    private SObject getOldValues() {
        return oldRecord;
    }

    /**
    * @description Sets the matching old values of the record attribute.
    * Returns the class for chaining 
    * @author NickHolly | 03-16-2022 
    * @param oldRecord 
    * @return SObjectHelper 
    **/
    public SObjectHelper setOldValues(SObject oldRecord) {
        if (this.record?.Id != oldRecord.Id) {
            throw new SObjectHelperException('Values must be for the same record.');
        }
        this.oldRecord = oldRecord;
        return this;
    }

    /**
    * @description 
    * @author NickHolly | 03-16-2022 
    * @param firstValue 
    * @param secondValue 
    * @return Boolean 
    **/
    private Boolean isFieldChanged(
        Object firstValue, 
        Object secondValue
    ) {
        return !(firstValue == secondValue);
    }

    /**
    * @description 
    * @author NickHolly | 03-16-2022 
    * @return List<String> 
    **/
    public List<String> getChangedFields() {
        return this.getChangedFields(null);
    }   

    /**
    * @description 
    * @author NickHolly | 03-16-2022 
    * @param fieldsToEvaluate 
    * @return List<String> 
    **/
    public List<String> getChangedFields(Set<String> fieldsToEvaluate) {
        if (
            this.record == null ||
            this.oldRecord == null
        ) {
            throw new SObjectHelperException('Current Values and Old Values must be set before evaluation.');
        }
        List<String> changedFields = new List<String>();
        //iterate over all populated fields if the fieldsToEvaluate parameter is null, otherwise only iterate over the fieldsToEvaluate.
        for (String fieldName :(fieldsToEvaluate == null ? this.record.getPopulatedFieldsAsMap().keySet() : fieldsToEvaluate)) {
            if (isFieldChanged(
                this.record.get(fieldName),
                this.oldRecord.get(fieldName)
            )) {
                changedFields.add(fieldName);
            }
        }
        return changedFields;
    }

    public class SObjectHelperException extends Exception {

    }
}