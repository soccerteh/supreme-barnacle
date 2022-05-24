public with sharing class MetadataUtils {
    public MetadataUtils() {

    }

    public static Map<String, Student_File__mdt> getActiveStudentFileMetadata() {
        Map<String, Student_File__mdt> studentFiles = new Map<String, Student_File__mdt>();
        for(Student_File__mdt setting :[SELECT MasterLabel, Field_API_Name__c, Submission_Field_API_Name__c 
                                        FROM Student_File__mdt 
                                        WHERE isActive__c = true
                                        ORDER BY MasterLabel]
        ){
            studentFiles.put(setting.MasterLabel, setting);
        }
        return studentFiles;
    }

    public static String getActiveStudentFileQueryFields() {
        Set<String> fields = new Set<String>();
        
        for(Student_File__mdt setting :getActiveStudentFileMetadata().values()) {
            fields.add(setting.Field_API_Name__c);
        }
        return String.join(new List<String>(fields), ',');
    }

}