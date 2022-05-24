public without sharing class CioIntegrationServices {
    

    public CioIntegrationServices() {
    }

    public static void syncRecords(
        CIO_Integration_Setting__mdt integrationSetting,
        Map<Id, SObject> records
    ) {
        System.enqueueJob( new CioIntegrationEvent(
            integrationSetting,
            records.keySet()
        ));
    }

    public static void syncRecords(
        CIO_Integration_Setting__mdt integrationSetting,
        Map<Id, SObject> oldRecords,
        Map<Id, SObject> newRecords
    ) {
        List<SObject> recordsToSync = new List<SObject>();
        if (integrationSetting.Watch_Fields__c != null) {
            for (SObject record :newRecords.values()) {
                //do logic filtering by watch fields.
                if (getIntegrationSyncRequired(
                    oldRecords.get(record.Id), 
                    record,
                    integrationSetting.Watch_Fields__c
                )) {
                    recordsToSync.add(record);
                }
            }
        } else {
            recordsToSync.addAll(newRecords.values());
        }
        if (!recordsToSync.isEmpty()) {
            syncRecords(
                integrationSetting, 
                new Map<Id, SObject>(recordsToSync)
            );
        }
    }

    public static Boolean getIntegrationSyncRequired(
        SObject oldValue,
        SObject newValue,
        String fieldsToWatch
    ) {
        Set<String> fieldsToWatchForChanges = getFieldsToWatch(fieldsToWatch);
        return !(
            new SObjectHelper()
                .setCurrentValues(newValue)
                .setOldValues(oldValue)
                .getChangedFields(fieldsToWatchForChanges)
                .isEmpty()
        );
    }
    
    private static Set<String> getFieldsToWatch(String fieldsToWatchString) {
        return new Set<String>(fieldsToWatchString.split(',')); 
    }

    public class CioIntegrationEvent implements Queueable, Database.AllowsCallouts {
        CIO_Integration_Setting__mdt integrationSetting;
        Set<Id> recordIds;

        public CioIntegrationEvent(
            CIO_Integration_Setting__mdt integrationSetting,
            Set<Id> recordIds
        ) {
            this.integrationSetting = integrationSetting;
            this.recordIds = recordIds;
        }

        public void execute(System.QueueableContext context) {
            if (this.recordIds.size() > 200) {
                throw new CioIntegrationServicesException('Cannot sync more than 200 records at a time.');
            }
            List<HttpRequest> requests = new List<HttpRequest>();
            for (SObject record :getQueryResults()) {
                HttpRequest request = new HttpRequest();
                String payload = getPayload(record);
                String email = getEmail(record);
                String endpoint = 'callout:Customer_IO_Production/' + email + (this.integrationSetting.Endpoint_Extension__c == null ? '' : this.integrationSetting.Endpoint_Extension__c);
                request.setEndpoint(endpoint);
                request.setMethod(this.integrationSetting.Endpoint_Method__c);
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                request.setHeader('Content-Length', String.valueOf(payload.length()));
                request.setBody(payload);
                requests.add(request);
            }
            if (!requests.isEmpty()) {
                if (TriggerHandler.getIsTestRunning()) {
                    return;
                }
                HttpRequests.makeRequests(
                    requests,
                    new List<String>{'Content-Type', 'Content-Length'}
                );
            }
        }

        @TestVisible
        private List<SObject> getQueryResults() {
            Set<String> ids = new Set<String>();
            for (Id recordId :this.recordIds) {
                ids.add(String.valueOf(recordId));
            }
            //Unfortunately the getInstance method for Custom Metadata objects only retrieves the first 255 characters.
            //It is then required to query this value in order to retrieve the full value for the query.
            //Below string assignment broken up for ease of reading.
            String query = 
                'SELECT ' + 
                [SELECT Fields_To_Query__c FROM CIO_Integration_Setting__mdt WHERE MasterLabel = :this.integrationSetting.MasterLabel LIMIT 1].Fields_To_Query__c + 
                ' FROM ' + 
                this.integrationSetting.SObject__c + ' WHERE Id IN :ids';
            return Database.query(query);
        }

        @TestVisible
        private String getPayload(SObject record) {
            if (this.integrationSetting.Type__c == 'Profile') {
                return getCioProfileBody(record);
            } else {
                return getCioEventBody(record);
            }
        }

        private String getCioProfileBody(SObject record) {
            return JSON.serializePretty(
                new CioProfile().build(record),
                true   
            );
        }

        private String getCioEventBody(SObject record) {
            return JSON.serializePretty(
                new CioEvent().setName(this.integrationSetting.MasterLabel).build(record),
                true
            );            
        }

        @TestVisible
        private String getEmail(SObject record) {
            switch on this.integrationSetting.SObject__c {
                when 'Account' {
                    return (String)record.get('Email__c');
                }
                when 'Application__c' {
                    return (String)record.get('Applicant_Email__c');
                } when 'Enrollment_Record__c' {
                    Enrollment_Record__c enrollment = (Enrollment_Record__c) record;
                    return enrollment.Student_Account__r.Email__c;
                }
                when 'Inquiry__c' {
                    return (String)record.get('Email__c');
                }
                when 'Opportunity' {
                    Opportunity opp = (Opportunity) record;
                    return opp.Account.Email__c;
                }
                when 'Lead' {
                    return (String)record.get('Email');
                }
                when else {
                    return null;
                }
            }
        }
    }

    private class CioIntegrationServicesException extends Exception {

    }
}