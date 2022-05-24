/**
 * Auto Generated and Deployed by Fast Prefill - Formstack
 **/
trigger FFPrefill_Trigger08FC0 on Enrollment_Record__c
    (after insert)
{
 if  (trigger.isAfter  &&  trigger.isInsert) { 
List<Enrollment_Record__c>  newlyInsertedItems =  [SELECT  Id ,  Enrollment_Form_Link__c FROM  Enrollment_Record__c WHERE  Id  IN :trigger.new] ; 
List<string> ids = new List<string>();
 for ( Enrollment_Record__c e  : newlyInsertedItems) { 
ids.add(e.id); 
} 
 VisualAntidote.FastFormsUtilities.DoUpdateRecords( 'Enrollment_Record__c' ,  'Enrollment_Form_Link__c' ,  'a0w3h000000ZRt3AAG' ,  ids,null );  
 update newlyInsertedItems;}
}