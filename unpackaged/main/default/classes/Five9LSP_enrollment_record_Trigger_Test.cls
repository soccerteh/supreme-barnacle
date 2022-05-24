/*
 * This is the test class for "Five9LSP_enrollment_record_Trigger" apex class.
 * Created on:11-02-2022
 */
@isTest
public class Five9LSP_enrollment_record_Trigger_Test {
    
    @testSetup static void testSetupData() {
        
        Profile p 	= [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u 		= new User(
            					Alias = 'standt', 
            					Email='standarduser@testorg.com', 
                               	EmailEncodingKey='UTF-8', 
            					LastName='Testing', 
            					LanguageLocaleKey='en_US', 
                               	LocaleSidKey='en_US', 
            					ProfileId = p.Id, 
                               	TimeZoneSidKey='America/Los_Angeles', 
            					UserName='standarduser@testorg.com'+System.now().millisecond(),
                               	Override_Workflow__c = true
        					);
        insert u;  
        
    }//end:testSetupData()    
	
    @isTest
    public static void testInsert(){
               
        User usr = [SELECT Id FROM User WHERE email = 'standarduser@testorg.com'];

    	System.runAs(usr) { 
            
         	Id recordTypeId = [SELECT Id FROM RecordType
    							WHERE DeveloperName = 'University' AND sObjectType = 'Account'].Id;  
            // Create a test account
            Account testAcct = new Account (
                							Name = 'Test Account'+System.now().millisecond(),
                                            RecordTypeId = recordTypeId, website='Test.com'
            								);
            insert testAcct;
            
            Program__c testProg = new Program__c(
                									Name='London - Fall 2022'+System.now().millisecond(),
                                                    Program_Start_Date__c = System.today().addDays(-5),
                                                    Program_End_Date__c = System.today().addDays(10)
            									);
            insert testProg;
            
            // Creates first opportunity
            Opportunity testOppt = new Opportunity(
                									Name ='New mAWS Deal'+System.now().millisecond(),
                                               		AccountID = testAcct.Id,
                                               		StageName = 'Customer Won',
                                               		Amount = 3000,
                                               		CloseDate = System.today()
            									);
            
            insert testOppt;
                       
            Enrollment_Record__c testEnroll = new Enrollment_Record__c(
                                                                       Opportunity__c = testOppt.Id,
            														   Program__c = testProg.Id            
            														);
            insert testEnroll;
        }

    }//end:testInsert()
    
    @isTest
    public static void testUpdate(){
        
        User usr = [SELECT Id FROM User WHERE email = 'standarduser@testorg.com'];

    	System.runAs(usr) {
            
           Id recordTypeId = [SELECT Id FROM RecordType
    							WHERE DeveloperName = 'University' AND sObjectType = 'Account'].Id;   
                                
            // Create a test account
            Account testAcct = new Account (
                							Name = 'Test Account'+System.now().millisecond(),
                                            RecordTypeId = recordTypeId, website='Test.com'
            								);
            insert testAcct;
            
            Program__c testProg = new Program__c(
                									Name='London - Fall 2022'+System.now().millisecond(),
                                                    Program_Start_Date__c = System.today().addDays(-5),
                                                    Program_End_Date__c = System.today().addDays(10)
            									);
            insert testProg;
            
            // Creates first opportunity
            Opportunity testOppt = new Opportunity(
                									Name ='New mAWS Deal'+System.now().millisecond(),
                                               		AccountID = testAcct.Id,
                                               		StageName = 'Customer Won',
                                               		Amount = 3000,
                                               		CloseDate = System.today()
            									);
            
            insert testOppt;            
                       
            Enrollment_Record__c testEnroll = new Enrollment_Record__c(
                                                                       Opportunity__c = testOppt.Id,
            														   Program__c = testProg.Id);
            insert testEnroll;
            
            if(!String.isEmpty(testEnroll.Id)){
                
                testEnroll.Interest_Level__c = '1';
                update testEnroll;
                
                delete testEnroll;
            }
            
        }
    }//end: testUpdate()
}