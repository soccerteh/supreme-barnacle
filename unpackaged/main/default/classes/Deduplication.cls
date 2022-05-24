public without sharing class Deduplication {
    
    public Deduplication() {

    }
    public static List<DuplicateRecordSet> findDuplicates(List<Sobject> records) {
         return findDuplicates(records, false);
    }

    public static List<DuplicateRecordSet> findDuplicates(
        List<SObject> records,
        Boolean mergeRecords
    ) {
        if(records.isEmpty()){
            return new List<DuplicateRecordSet>();
        }
        SObjectType recordsObjectType = records.getSObjectType();
        Map<String, DuplicateRule> duplicateRules = getDuplicateRules(recordsObjectType.getDescribe().getName());
        if(duplicateRules.isEmpty()) {
            //return as there are no active duplicate rules to evaluate.
            return new List<DuplicateRecordSet>();
        }
        List<Datacloud.FindDuplicatesResult> results = Datacloud.FindDuplicates.findDuplicates(records);
        Set<String> potentialDuplicateIds = new Set<String>();
        List<DuplicateSet> duplicateSets = new List<DuplicateSet>();
        List<DuplicateRecordSet> duplicateRecordSets = new List<DuplicateRecordSet>();
        for(Integer i = 0; i < results.size(); i++) {
            String recordId = records[i].Id;
            if(potentialDuplicateIds.contains(recordId)) {
                continue;
            }
            //put specific duplicate results for the current record that is being iterated over
            for(Datacloud.DuplicateResult dupeResult :results[i].getDuplicateResults()) {
                for(Datacloud.MatchResult matchResult :dupeResult.getMatchResults()) {
                    //If there are duplicates, add iterated record ID to confirmed dupes collection to prevent inclusions later. 
                    if(matchResult.getSize() != 0) {
                        potentialDuplicateIds.add(recordId);
                        //Create DuplicateRecordSet
                        DuplicateSet dupeSet = new DuplicateSet();
                        DuplicateRecordSet duplicateSet = new DuplicateRecordSet(
                            DuplicateRuleId = duplicateRules.get(dupeResult.getDuplicateRule()).Id
                        );
                        dupeSet.duplicateInfo = duplicateSet;
                        DuplicateRecordItem duplicateItem = new DuplicateRecordItem(
                            RecordId = recordId
                        );
                        dupeSet.duplicateRecords.add(duplicateItem);
                        for(Datacloud.MatchRecord matchRecord :matchResult.getMatchRecords()) {
                            duplicateItem = new DuplicateRecordItem(
                                recordId = matchRecord.getRecord().Id
                            );
                            potentialDuplicateIds.add(duplicateItem.recordId);
                            dupeSet.duplicateRecords.add(duplicateItem);
                        }
                        duplicateRecordSets.add(duplicateSet);
                        duplicateSets.add(dupeSet);
                    } 
                }
            }
        }
        if(!duplicateRecordSets.isEmpty()){
            insert duplicateRecordSets;

            List<DuplicateRecordItem> duplicateRecordItems = new List<DuplicateRecordItem>();
            for(DuplicateSet each :duplicateSets) {
                each.relateDuplicateRecords();
                duplicateRecordItems.addAll(each.duplicateRecords);
            }
            insert duplicateRecordItems;
        }

        //enqueue a job to merge the records.
        return duplicateRecordSets;
    }

    private static Map<String, DuplicateRule> getDuplicateRules(String duplicateRuleEntityType) {
        Map<String, DuplicateRule> duplicateRules = new Map<String, DuplicateRule>();
        for(DuplicateRule rule :[SELECT Id, DeveloperName FROM DuplicateRule WHERE isActive = true AND SobjectType = :duplicateRuleEntityType]) {
            duplicateRules.put(rule.DeveloperName, rule);
        }
        return duplicateRules;
    }

    public class DuplicateSet {
        public DuplicateRecordSet duplicateInfo;
        public List<DuplicateRecordItem> duplicateRecords;

        public DuplicateSet() {
            duplicateRecords = new List<DuplicateRecordItem>();
        }

        public void relateDuplicateRecords() {
            for(DuplicateRecordItem duplicate :duplicateRecords) {
                duplicate.DuplicateRecordSetId = duplicateInfo.Id;
            }
        }
    }
}