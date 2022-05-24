/*
* @author          Dhatrinath Kodali
* @version         1
* @date            14-08-2020
* @description     This class is a test class for AutoConvertLeads.
*/
@isTest
public class AutoConvertLeadsTest {
    @isTest
    static void testM(){
        Application__c refObject0 = new Application__c(Name='test app', Applicant_First_Name__c = 'Test', Applicant_Last_Name__c = 'Applicant');
        insert refObject0;

        Lead objLead = new Lead( FirstName = 'TestLeadConversion', LastName = '2', Company = 'Testing Sample Co', Application__c = FALSE,Email = 'test123@test.com', Associated_Application__c = refObject0.Id);  
        insert objLead;  
        
        AutoConvertLeads.LeadAssign(new List<Id>{objLead.Id});
    }
}