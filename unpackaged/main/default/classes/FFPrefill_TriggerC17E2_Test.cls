/**
 * Auto Generated and Deployed by Fast Prefill - Formstack
 **/
@IsTest
private class FFPrefill_TriggerC17E2_Test
{
    @IsTest
private static void testTrigger()
    {
   Test.startTest();
   Opportunity refObject0 = new Opportunity(Name='test',StageName=getPickValue('Opportunity','StageName'),CloseDate=system.today());
 insert refObject0 ;
   Program__c refObject1 = new Program__c(Name='test program', Program_Start_Date__c = System.today(), Program_End_Date__c = System.today().addMonths(3));
   insert refObject1;
   Enrollment_Record__c primaryObject= new Enrollment_Record__c(Opportunity__c=refObject0.Id, Program__c=refObject1.Id);
 insert primaryObject;
   Test.stopTest(); 
 System.assertNotEquals(primaryObject.Id,null);   
 }

 static String getPickValue(String objName, String fld){ 
 String firstPicklistVal=''; 
  Schema.SObjectType sobjectType= Schema.getGlobalDescribe().get(objName);   
  // Get a map of fields for the SObject 
 map<String, Schema.SObjectField> fieldMap = sobjectType.getDescribe().fields.getMap(); 
  // Get the list of picklist values for this field. 
 list<Schema.PicklistEntry> values = 
 fieldMap.get(fld).getDescribe().getPickListValues(); 
 // Add these values to the selectoption list. 
 if(values!=null && values.size()>0){ firstPicklistVal=values[0].getValue()+'';} 
 return firstPicklistVal; 
 } 

}