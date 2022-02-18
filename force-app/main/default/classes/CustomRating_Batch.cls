/**********************************************************************************************************
* Class Name: CustomRating_Batch
* Author: KGS
*
* ============================================================================================================
* ============================================================================================================
* Purpose: This batch class updates the rating value based on percentage
* ============================================================================================================
* ============================================================================================================
* History:
* VERSION     DATE                  INITIALS      DESCRIPTION/FEATURES ADDED
* 1.0         01-November-2021      KGS           Initial Development
***********************************************************************************************************/
global class CustomRating_Batch implements Database.Batchable<sObject>,Database.Stateful{
    
    Integer ratingCount1 = 0;
    Integer ratingCount2 = 0;
    Integer ratingCount3 = 0; 
    String ratingField;
    Id enqueueJobId;
    Integer iterationCount;
    
    CustomRating_Global_Setting__c globalSettingObj = CustomRating_Utility.getCustomRatingGlobalSetting();
    
    
    global CustomRating_Batch(String ratingField,Id enqueueJobId,Integer iterationCount){
        this.ratingField = ratingField;
        this.enqueueJobId = enqueueJobId;
        this.iterationCount = iterationCount;
    }
    
    // Collect the batches of records or objects to be passed to execute
    global Database.QueryLocator start(Database.BatchableContext bc) { 
        String query;        
        
        List<AggregateResult> sObjList = CustomRating_Utility.fetchSobjectCount(globalSettingObj,ratingField);        
        Integer listSize = Integer.valueOf(sObjList[0].get('expr0'));
        
        ratingCount1 = CustomRating_Utility.calculateRatingCounts(listSize,globalSettingObj.Custom_Rating_1_Percentage__c);
        ratingCount2 = CustomRating_Utility.calculateRatingCounts(listSize,globalSettingObj.Custom_Rating_2_Percentage__c);
        ratingCount3 = CustomRating_Utility.calculateRatingCounts(listSize,globalSettingObj.Custom_Rating_3_Percentage__c); 
        
        System.debug('ratingCount1==>'+ratingCount1);
        System.debug('ratingCount2==>'+ratingCount2);
        System.debug('ratingCount3==>'+ratingCount3);       
        
        query =  CustomRating_Utility.SELECT_STR + globalSettingObj.Custom_Rating_Field__c;
        query += CustomRating_Utility.FROM_STR + globalSettingObj.Object_Name__c;
        query += CustomRating_Utility.WHERE_STR;
        query += globalSettingObj.Custom_Rating_Group_Field__c + ' = ' + '\'' + ratingField + '\'';
        
        if(globalSettingObj.Rating_Criteria__c != null){
            query += ' AND ' + globalSettingObj.Rating_Criteria__c;
        }         
        
        if(String.isNotBlank(globalSettingObj.Rating_Rollup_Sort_Order_Criteria__c)){
            query += CustomRating_Utility.ORDER_BY_STR + ' ';
            query += globalSettingObj.Rating_Rollup_Sort_Order_Criteria__c;
        }
        
        System.debug('query==>'+query);
        return Database.getQueryLocator(query);        
    }
    
    // process each batch of records to update the rating values based on percentage.
    global void execute(Database.BatchableContext bc, List<sObject> sObjectList){
        Map<Id,sObject> sObjMap = new Map<Id,sObject>();
        System.debug('accountList size==>'+sObjectList.size()); 
        
        for(sObject obj :sObjectList){
            // Create the object based on Id.
            sObject sObj = obj.Id.getSobjectType().newSObject(obj.Id);
            if(ratingCount1 > 0){
                sObj.Put(globalSettingObj.Custom_Rating_Field__c,globalSettingObj.Rating_Value_1__c);
                ratingCount1 = ratingCount1 - 1;
                sObjMap.put(obj.Id, sObj);
                continue;
            }  
            if(ratingCount1 == 0 && ratingCount2 > 0){                
                sObj.Put(globalSettingObj.Custom_Rating_Field__c,globalSettingObj.Rating_Value_2__c);    
                ratingCount2 = ratingCount2 -1;        
                sObjMap.put(obj.Id, sObj);
                continue;
            }    
            
            if(ratingCount1 == 0 && ratingCount2 == 0 && ratingCount3 > 0){
                sObj.Put(globalSettingObj.Custom_Rating_Field__c,globalSettingObj.Rating_Value_3__c);
                ratingCount3 = ratingCount3 -1;
                sObjMap.put(obj.Id, sObj);
                continue;
            }
        }
        
        System.debug('sObjMap size==>'+sObjMap);
        // Update the values
        if(!sObjMap.isEmpty()){
            Update sObjMap.values(); 
        } 
    }
    
    // execute any post-processing operations
    global void finish(Database.BatchableContext bc){
        if(enqueueJobId != null){
            // Abort the current job.
            system.abortJob(enqueueJobId);          
            // Increment the iteration count to run the batch for the next picklist value.
            Integer IncrementedCount = iterationCount+1;
            // Enqueue the job to run batch
            System.enqueueJob(new CustomRating_Queueable(IncrementedCount));
        }
        
        
    }     

}