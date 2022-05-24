/**
 * @description       : 
 * @author            : Thomas E. Hamilton
 * @group             : 
 * @last modified on  : 01-20-2022
 * @last modified by  : Thomas E. Hamilton
**/
@isTest
public without sharing class FlowUtils_Tests {
    //Everything should run in system context because that is how most of the flows run that access this class

    @TestSetup
    static void makeData(){
        //Account
        Account acc = new Account(
            Name = 'test',
            First_Name__c = 'test',
            Last_Name__c = 'user'
        );
        insert acc;

        //Program
        Program__c pro = new Program__c(
            Name = 'test',
            Program_Start_Date__c = system.today(),
            Program_End_Date__c = system.today() + 90
        );
        insert pro;

        //Flight
        Flight__c flight = new Flight__c(
            Name = 'test'
        );
        insert flight;
    }

    //Account Id & Program Id populated
    @isTest
    static void testCheckId(){
        string accountId = (String)[SELECT Id FROM Account WHERE Name = 'test user'].Id;
        string programId = (String)[SELECT Id FROM Program__c WHERE Name = '-'].Id;

        FlowUtils.FlowUtilsVars setAccountVars = new FlowUtils.FlowUtilsVars();
        setAccountVars.inputObject = 'Account';
        setAccountVars.inputId = accountId;

        FlowUtils.FlowUtilsVars setProgramVars = new FlowUtils.FlowUtilsVars();
        setProgramVars.inputObject = 'Program__c';
        setProgramVars.inputId = programId;


        Test.startTest();

        //Check Account
        List<Boolean> results = FlowUtils.checkId(new List<FlowUtils.FlowUtilsVars>{setAccountVars});
        for(Boolean result : results){
            System.assertEquals(true, result, 'Expected true when passing accurate Account Id');
        }

        //Check Program
        results = FlowUtils.checkId(new List<FlowUtils.FlowUtilsVars>{setProgramVars});
        for(Boolean result : results){
            System.assertEquals(true, result, 'Expected true when passing accurate Program Id');
        }

        Test.stopTest();
    }

    //Account null program populated
    @isTest
    static void testAccountIdNull(){
        string programId = (String)[SELECT Id FROM Program__c WHERE Name = '-'].Id;

        FlowUtils.FlowUtilsVars setAccountVars = new FlowUtils.FlowUtilsVars();
        setAccountVars.inputObject = 'Account';
        setAccountVars.inputId = '';

        FlowUtils.FlowUtilsVars setProgramVars = new FlowUtils.FlowUtilsVars();
        setProgramVars.inputObject = 'Program__c';
        setProgramVars.inputId = programId;

        Test.startTest();
        //Check Account
        List<Boolean> results = FlowUtils.checkId(new List<FlowUtils.FlowUtilsVars>{setAccountVars});
        for(Boolean result : results){
            System.assertEquals(false, result, 'Expected false when passing null Account Id');
        }

        //Check Program
        results = FlowUtils.checkId(new List<FlowUtils.FlowUtilsVars>{setProgramVars});
        for(Boolean result : results){
            System.assertEquals(true, result, 'Expected true when passing accurate Program Id');
        }

        Test.stopTest();

    }

    //Both null
    @isTest
    static void testBothNull(){
        FlowUtils.FlowUtilsVars setAccountVars = new FlowUtils.FlowUtilsVars();
        setAccountVars.inputObject = 'Account';
        setAccountVars.inputId = '';

        FlowUtils.FlowUtilsVars setProgramVars = new FlowUtils.FlowUtilsVars();
        setProgramVars.inputObject = 'Program__c';
        setProgramVars.inputId = '';
        
        Test.startTest();
        //Check Account
        List<Boolean> results = FlowUtils.checkId(new List<FlowUtils.FlowUtilsVars>{setAccountVars});
        for(Boolean result : results){
            System.assertEquals(false, result, 'Expected false when passing null Account Id');
        }

        //Check Program
        results = FlowUtils.checkId(new List<FlowUtils.FlowUtilsVars>{setProgramVars});
        for(Boolean result : results){
            System.assertEquals(false, result, 'Expected false when passing null Program Id');
        }

        Test.stopTest();
    }

    //Account w/ bad data - program populated
    @isTest 
    static void testBadAccountId(){
        string programId = (String)[SELECT Id FROM Program__c WHERE Name = '-'].Id;

        FlowUtils.FlowUtilsVars setAccountVars = new FlowUtils.FlowUtilsVars();
        setAccountVars.inputObject = 'Account';
        setAccountVars.inputId = '%5Bnetid2%5D';

        FlowUtils.FlowUtilsVars setProgramVars = new FlowUtils.FlowUtilsVars();
        setProgramVars.inputObject = 'Program__c';
        setProgramVars.inputId = programId;

        Test.startTest();
        //Check Account
        List<Boolean> results = FlowUtils.checkId(new List<FlowUtils.FlowUtilsVars>{setAccountVars});
        for(Boolean result : results){
            System.assertEquals(false, result, 'Expected false when passing invalid Account Id');
        }

        //Check Program
        results = FlowUtils.checkId(new List<FlowUtils.FlowUtilsVars>{setProgramVars});
        for(Boolean result : results){
            System.assertEquals(true, result, 'Expected true when passing accurate Program Id');
        }

        Test.stopTest();
    }

    //Account & program w/ bad data
    @isTest 
    static void testBadIds(){
        FlowUtils.FlowUtilsVars setAccountVars = new FlowUtils.FlowUtilsVars();
        setAccountVars.inputObject = 'Account';
        setAccountVars.inputId = '%5Bnetid2%5D';

        FlowUtils.FlowUtilsVars setProgramVars = new FlowUtils.FlowUtilsVars();
        setProgramVars.inputObject = 'Program__c';
        setProgramVars.inputId = '%5Bnetid2%5D';

        Test.startTest();
        //Check Account
        List<Boolean> results = FlowUtils.checkId(new List<FlowUtils.FlowUtilsVars>{setAccountVars});
        for(Boolean result : results){
            System.assertEquals(false, result, 'Expected false when passing invalid Account Id');
        }

        //Check Program
        results = FlowUtils.checkId(new List<FlowUtils.FlowUtilsVars>{setProgramVars});
        for(Boolean result : results){
            System.assertEquals(false, result, 'Expected false when passing invalid Program Id');
        }

        Test.stopTest();
    }
    
    //Account populated & program w/ bad data
    @isTest 
    static void testBadProgram(){
        string accountId = (String)[SELECT Id FROM Account WHERE Name = 'test user'].Id;

        FlowUtils.FlowUtilsVars setAccountVars = new FlowUtils.FlowUtilsVars();
        setAccountVars.inputObject = 'Account';
        setAccountVars.inputId = accountId;

        FlowUtils.FlowUtilsVars setProgramVars = new FlowUtils.FlowUtilsVars();
        setProgramVars.inputObject = 'Program__c';
        setProgramVars.inputId = '%5Bnetid2%5D';

        Test.startTest();
        //Check Account
        List<Boolean> results = FlowUtils.checkId(new List<FlowUtils.FlowUtilsVars>{setAccountVars});
        for(Boolean result : results){
            System.assertEquals(true, result, 'Expected true when passing valid Account Id');
        }

        //Check Program
        results = FlowUtils.checkId(new List<FlowUtils.FlowUtilsVars>{setProgramVars});
        for(Boolean result : results){
            System.assertEquals(false, result, 'Expected false when passing invalid Program Id');
        }

        Test.stopTest();
    }

    //Account and program populated w/ another object's Id and program populated
    @isTest 
    static void testNonMatchingIdAndObject(){
        String flightId = (String)[SELECT Id FROM Flight__c WHERE Name = '- Flight Record'].Id;

        FlowUtils.FlowUtilsVars setAccountVars = new FlowUtils.FlowUtilsVars();
        setAccountVars.inputObject = 'Account';
        setAccountVars.inputId = flightId;

        FlowUtils.FlowUtilsVars setProgramVars = new FlowUtils.FlowUtilsVars();
        setProgramVars.inputObject = 'Program__c';
        setProgramVars.inputId = flightId;

        Test.startTest();
        //Check Account
        List<Boolean> results = FlowUtils.checkId(new List<FlowUtils.FlowUtilsVars>{setAccountVars});
        for(Boolean result : results){
            System.assertEquals(false, result, 'Expected false when passing a Flight Id with an Account object');
        }

        //Check Program
        results = FlowUtils.checkId(new List<FlowUtils.FlowUtilsVars>{setProgramVars});
        for(Boolean result : results){
            System.assertEquals(false, result, 'Expected false when passing a Flight id with a Program object');
        }

        Test.stopTest();
    }
}