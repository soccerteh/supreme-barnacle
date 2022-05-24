public virtual class TriggerHandler {

    private TriggerOperation operationType;
    private static Set<String> suppressedHandlers;
    /* private static Map<String, LoopIterations> triggerLimits; */
    private Boolean isValid;
    private static Boolean isTestRunning;

    static {
        suppressedHandlers = new Set<String>();
        /* triggerLimits = new Map<String, LoopIterations>(); */
    }

    public TriggerHandler() {
        this.setOperationType(null);
    }
    
    public void run() {
        getIsValid();
        if (!this.isValid) {
            return;
        }
        switch on operationType {
            when BEFORE_INSERT {
                this.beforeInsert();
            }
            when BEFORE_UPDATE {
                this.beforeUpdate();
            }
            when BEFORE_DELETE {
                this.beforeDelete();
            }
            when AFTER_INSERT {
                this.afterInsert();
            }
            when AFTER_UPDATE {
                this.afterUpdate();
            }
            when AFTER_DELETE {
                this.afterDelete();
            }
        }
    }
    /** Public static methods */
    public static void suppressHandler(String handlerName) {
        TriggerHandler.suppressedHandlers.add(handlerName);
    }

    public static void unsuppressHandler(String handlerName) {
        TriggerHandler.suppressedHandlers.remove(handlerName);
    }

    public static void clearSuppressedHandlers() {
        TriggerHandler.suppressedHandlers = new Set<String>();
    }

    public static Boolean getIsSuppressed(String handlerName) {
        return TriggerHandler.suppressedHandlers.contains(handlerName);
    }
    public static Boolean getIsTestRunning() {
        if (TriggerHandler.isTestRunning == null) {
            TriggerHandler.isTestRunning = Test.isRunningTest();
        }
        return TriggerHandler.isTestRunning;
    }

    /** Public methods for Limits */
    /* public void setTriggerLimit(Integer maxTotalIterations) {
        TriggerHandler.triggerLimits.put(
            getCurrentHandler(), 
            new LoopIterations().setMaxIterations(maxTotalIterations));
    } */

    /** Private instance methods */
    private void getIsValid() {
        if (
            this.operationType == null ||
            TriggerHandler.suppressedHandlers.contains(getCurrentHandler())
        ) {
            this.isValid = false;
        } else {
            this.isValid = true;
        }
    }

    private String getCurrentHandler() {
        return String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    }
    
    /** Private test utility methods */
    @TestVisible
    private void setOperationType(TriggerOperation operationType) {
        this.operationType = operationType == null ? (Trigger.operationType) : operationType;
    }

    @TestVisible
    private static void setIsTestRunning(Boolean isTestRunning) {
        TriggerHandler.isTestRunning = isTestRunning;
    }

    /** Virtual Methods to be overridden */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    //This method should be overridden by the derived class.
    @TestVisible
    protected virtual void beforeInsert() {

    }
    @SuppressWarnings('PMD.EmptyStatementBlock')
    //This method should be overridden by the derived class.
    @TestVisible
    protected virtual void beforeUpdate() {

    }
    @SuppressWarnings('PMD.EmptyStatementBlock')
    //This method should be overridden by the derived class.
    @TestVisible
    protected virtual void beforeDelete() {

    }
    @SuppressWarnings('PMD.EmptyStatementBlock')
    //This method should be overridden by the derived class.
    @TestVisible
    protected virtual void afterInsert() {

    }
    @SuppressWarnings('PMD.EmptyStatementBlock')
    //This method should be overridden by the derived class.
    @TestVisible
    protected virtual void afterUpdate() {

    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    //This method should be overridden by the derived class.
    @TestVisible
    protected virtual void afterDelete() {

    }

    /* @TestVisible
    private class LoopIterations {
        private Map<String, Map<String, Integer>> operationTypeLimits;
        private Integer maxIterations;
        private Integer currentIterations;

        public LoopIterations() {
            this.operationTypeLimits.put(
                'BEFORE_INSERT',
                new Map<String, Integer>()
            );
            this.operationTypeLimits.put(
                'BEFORE_UPDATE',
                new Map<String, Integer>()
            );
            this.operationTypeLimits.put(
                'BEFORE_DELETE',
                new Map<String, Integer>()
            );
            this.operationTypeLimits.put(
                'AFTER_INSERT',
                new Map<String, Integer>()
            );
            this.operationTypeLimits.put(
                'AFTER_UPDATE',
                new Map<String, Integer>()
            );
            this.operationTypeLimits.put(
                'AFTER_DELETE',
                new Map<String, Integer>()
            );
            this.maxIterations = 5;
            this.currentIterations = 0;
        }

        private Integer getMaxIterations() {
            return this.maxIterations;
        }
        private Integer getOperationTypeIterationCount(String operationType) {
            return this.operationTypeLimits.get(operationType).get('count');
        }
        private Boolean getIsLimitSet() {
            return this.maxIterations != null;
        }
        private Boolean getIsOperationTypeLimitSet(String operationType) {
            return this.operationTypeLimits.get(operationType).containsKey('limit');
        }
        private Integer getCurrentIterations() {
            return this.currentIterations;
        }
        private Integer getOperationTypeLimit(String operationType) {
            return this.operationTypeLimits.get(operationType).get('limit');
        }
        private LoopIterations setMaxIterations(Integer maxIterations) {
            this.maxIterations = maxIterations;
            return this;
        }
        private LoopIterations setOperationTypeLimit(
            String operationType,
            Integer iterationLimit
        ) {
            this.operationTypeLimits.get(operationType).put('limit', iterationLimit);
            return this;
        }
        private void increment(String operationType) {
            this.operationTypeLimits.get(operationType).put('count', this.operationTypeLimits.get(operationType).get('count') + 1);
        }
    } */

    private class TriggerHandlerException extends Exception {}
}