/**********************************************************************************************************
* Class Name: CustomRating_RollupBatch
* Author: KGS
*
* ============================================================================================================
* ============================================================================================================
* Purpose: This batch class is used for field rollup of child records based on custom setting input.
* ============================================================================================================
* ============================================================================================================
* History:
* VERSION     DATE                  INITIALS      DESCRIPTION/FEATURES ADDED
* 1.0         01-November-2021      KGS           Initial Development
***********************************************************************************************************/
global class CustomRating_RollupBatch implements Database.Batchable<sObject>, database.stateful{
    
    public String query = '';
    Custom_Rating_Rollup_Batch_Settings__c customRatingSetting = Custom_Rating_Rollup_Batch_Settings__c.getInstance();
    CustomRating_Global_Setting__c globalSettingObj = CustomRating_Utility.getCustomRatingGlobalSetting();
    
    public string childRelationshipName = CustomRating_Utility.getChildRelationshipName(customRatingSetting);
    
    // Collect the batches of records or objects to be passed to execute
    global Database.QueryLocator start(Database.BatchableContext BC){
        try{
            
            if(customRatingSetting != null){
                
                query +=  CustomRating_Utility.SELECT_STR;
                query +=  customRatingSetting.Aggregate_Result_Field__c;
                query +=  CustomRating_Utility.FROM_STR;
                query +=  customRatingSetting.Parent_Object__c ;
                
                if(customRatingSetting.Relationship_Field_Criteria__c != null 
                  && String.isNotBlank(customRatingSetting.Relationship_Field_Criteria__c))
                {
                    query += ' WHERE ' + customRatingSetting.Relationship_Field_Criteria__c;
                }
                system.debug('query==>'+query);
            }
        } catch(Exception ex){
            system.debug('Exception ->'+ ex.getMessage());
        }
        return Database.getQueryLocator(query);
    }
    
    // Process each batch of records.
    global void execute(Database.BatchableContext BC, List<sObject> sObjectList){
        // This set holds the value of Parent Id.
        Set<String> parentIdSet = new Set<String>();
        
        // This map hold the parent Id and count of child records.
        Map<String,Integer> parentIdVsChildCountMap = new Map<String,Integer>();
        
        // This map updates the count on Parent Object.
        Map<Id,sObject> sObjMap = new Map<Id,sObject>();
        
        for(sObject parentObj : sObjectList){
            parentIdSet.add(parentObj.Id); 
        }
        
        List<AggregateResult> childSobjList = CustomRating_Utility.fetchChildObjectCounts(customRatingSetting,parentIdSet);
        for(AggregateResult arrObj : childSobjList){
            parentIdVsChildCountMap.put(String.valueof(arrObj.get(customRatingSetting.Relationship_Field__c)), Integer.valueof(arrObj.get('expr0')));
        }
        
        for(sObject obj :sObjectList){
            // Create the object based on Id.
            sObject sObj = obj.Id.getSobjectType().newSObject(obj.Id);
            if(parentIdVsChildCountMap.containskey(obj.Id)){
                sObj.Put(customRatingSetting.Aggregate_Result_Field__c,parentIdVsChildCountMap.get(obj.Id));                
            }else{
                sObj.Put(customRatingSetting.Aggregate_Result_Field__c,0);
            }
            sObjMap.put(obj.Id,sObj);               
        }
        
        // Update the values
        if(!sObjMap.isEmpty()){
            Update sObjMap.values(); 
        }         
    }
    
    // Execute any post-processing operations
    global void finish(Database.BatchableContext BC){
        // Enqueue the job to run CustomRating_Batch if Use_RollupBatch_for_Rollup_Field__c is true
        if(globalSettingObj.Use_RollupBatch_for_Rollup_Field__c == true){
            System.enqueueJob(new CustomRating_Queueable(0));
        }
    }  
}