@IsTest
public with sharing class TriggerHandlerTests {


    private static TestHandler handler;

    @IsTest
    static void testInvalidRun() {
        Test.startTest();
        handler = new TestHandler();
        handler.run();
        Test.stopTest();
        System.assertEquals(
            true,
            handler.methodsRan.isEmpty(),
            'Expected no methods to have run.'
        );
    }

    @IsTest
    static void testBeforeInsert() {
       
        Test.startTest();
        handler = new TestHandler();
        handler.setOperationType(TriggerOperation.BEFORE_INSERT);
        handler.run();
        Test.stopTest();
        System.assertEquals(
            true,
            handler.methodsRan.contains('beforeInsert'),
            'Expected the methods ran to contain \'beforeInsert\''
        );
    }

    @IsTest
    static void testBeforeUpdate() {
        
        Test.startTest();
        handler = new TestHandler();
        handler.setOperationType(TriggerOperation.BEFORE_UPDATE);
        handler.run();
        Test.stopTest();
        System.assertEquals(
            true,
            handler.methodsRan.contains('beforeUpdate'),
            'Expected the methods ran to contain \'beforeUpdate\''
        );
    }

    @IsTest
    static void testBeforeDelete() {
        
        Test.startTest();
        handler = new TestHandler();
        handler.setOperationType(TriggerOperation.BEFORE_DELETE);
        handler.run();
        Test.stopTest();
        System.assertEquals(
            true,
            handler.methodsRan.contains('beforeDelete'),
            'Expected the methods ran to contain \'beforeDelete\''
        );
    }

    @IsTest
    static void testAfterInsert() {
        
        Test.startTest();
        handler = new TestHandler();
        handler.setOperationType(TriggerOperation.AFTER_INSERT);
        handler.run();
        Test.stopTest();
        System.assertEquals(
            true,
            handler.methodsRan.contains('afterInsert'),
            'Expected the methods ran to contain \'afterInsert\''
        );
    }

    @IsTest
    static void testAfterUpdate() {
        
        Test.startTest();
        handler = new TestHandler();
        handler.setOperationType(TriggerOperation.AFTER_UPDATE);
        handler.run();
        Test.stopTest();
        System.assertEquals(
            true,
            handler.methodsRan.contains('afterUpdate'),
            'Expected the methods ran to contain \'afterUpdate\''
        );
    }

    @IsTest
    static void testAfterDelete() {
        
        Test.startTest();
        handler = new TestHandler();
        handler.setOperationType(TriggerOperation.AFTER_DELETE);
        handler.run();
        Test.stopTest();
        System.assertEquals(
            true,
            handler.methodsRan.contains('afterDelete'),
            'Expected the methods ran to contain \'afterDelete\''
        );
    }

    @IsTest
    static void testSupressedHandler() {
        Test.startTest();
        TriggerHandler.suppressHandler('TestHandler');
        handler = new TestHandler();
        handler.setOperationType(TriggerOperation.BEFORE_INSERT);
        handler.run();
        Test.stopTest();
        System.assertEquals(
            true,
            handler.methodsRan.isEmpty(),
            'Expected no methods to have run.'
        );
    }

    @IsTest
    static void testUnsuppressedHandler() {
        Test.startTest();
        TriggerHandler.suppressHandler('TestHandler');
        TriggerHandler.unsuppressHandler('TestHandler');
        handler = new TestHandler();
        handler.setOperationType(TriggerOperation.BEFORE_INSERT);
        handler.run();
        Test.stopTest();
        System.assertEquals(
            true,
            handler.methodsRan.contains('beforeInsert'),
            'Expected the methods ran to contain \'beforeInsert\''
        );
    }

    @IsTest
    static void testClearSuppressedHandlers() {
        Test.startTest();
        TriggerHandler.suppressHandler('TestHandler');
        TriggerHandler.suppressHandler('OpportunityHandler');
        TriggerHandler.clearSuppressedHandlers();
        handler = new TestHandler();
        handler.setOperationType(TriggerOperation.BEFORE_INSERT);
        handler.run();
        Test.stopTest();
        System.assertEquals(
            true,
            handler.methodsRan.contains('beforeInsert'),
            'Expected the methods ran to contain \'beforeInsert\''
        );
        System.assertEquals(
            false,
            TriggerHandler.getIsSuppressed('TestHandler'),
            'Expected the Test TriggerHandler to not be suppressed.'
        );
        System.assertEquals(
            false,
            TriggerHandler.getIsSuppressed('OppoortunityHandler'),
            'Expected the OpportunityHandler to not be suppressed.'
        );
    }

    @IsTest
    static void testGetIsTestRunning() {
        Test.startTest();
        System.assertEquals(
            true,
            TriggerHandler.getIsTestRunning(),
            'Expected the test to be running.'
        );
        Test.stopTest();
    }

    @IsTest
    static void testSetIsTestRunning() {
        Test.startTest();
        TriggerHandler.setIsTestRunning(false);
        System.assertEquals(
            false,
            TriggerHandler.getIsTestRunning(),
            'Expected the test to not be running.'
        );
    }

    private class TestHandler extends TriggerHandler {
        public List<String> methodsRan;

        public TestHandler() {
            methodsRan = new List<String>();
        }
        
        public override void beforeInsert() {
            if (methodsRan == null) {
                methodsRan = new List<String>();
            }
            this.methodsRan.add('beforeInsert');
        }
        public override void beforeUpdate() {
            if (methodsRan == null) {
                methodsRan = new List<String>();
            }
            this.methodsRan.add('beforeUpdate');
        }
        public override void beforeDelete() {
            if (methodsRan == null) {
                methodsRan = new List<String>();
            }
            this.methodsRan.add('beforeDelete');
        }
        public override void afterInsert() {
            if (methodsRan == null) {
                methodsRan = new List<String>();
            }
            this.methodsRan.add('afterInsert');
        }
        public override void afterUpdate() {
            if (methodsRan == null) {
                methodsRan = new List<String>();
            }
            this.methodsRan.add('afterUpdate');
        }
        public override void afterDelete() {
            if (methodsRan == null) {
                methodsRan = new List<String>();
            }
            this.methodsRan.add('afterDelete');
        }
    }

}