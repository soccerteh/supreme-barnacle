/**
 * Auto Generated and Deployed by Fast Prefill - Formstack
 **/
trigger FFPrefill_TriggerDCCED on Enrollment_Record__c
    (after insert)
{
 if  (trigger.isAfter  &&  trigger.isInsert) { 
List<Enrollment_Record__c>  newlyInsertedItems =  [SELECT  Id ,  Semester_Withdrawal_Form_Link__c FROM  Enrollment_Record__c WHERE  Id  IN :trigger.new] ; 
List<string> ids = new List<string>();
 for ( Enrollment_Record__c e  : newlyInsertedItems) { 
ids.add(e.id); 
} 
 VisualAntidote.FastFormsUtilities.DoUpdateRecords( 'Enrollment_Record__c' ,  'Semester_Withdrawal_Form_Link__c' ,  'a0w3h000000z7vNAAQ' ,  ids,null );  
 update newlyInsertedItems;}
}