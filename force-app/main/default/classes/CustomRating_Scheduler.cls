/**********************************************************************************************************
* Class Name: CustomRating_Scheduler
* Author: KGS
*
* ============================================================================================================
* ============================================================================================================
* Purpose: This class schedule the CustomRating_Batch and CustomRating_RollupBatch based on custom setting.
* ============================================================================================================
* ============================================================================================================
* History:
* VERSION     DATE                  INITIALS      DESCRIPTION/FEATURES ADDED
* 1.0         08-November-2021      KGS           Initial Development
***********************************************************************************************************/
global class CustomRating_Scheduler implements Schedulable{
    global void execute(SchedulableContext sc){        
        
        CustomRating_Global_Setting__c globalSettingObj = CustomRating_Utility.getCustomRatingGlobalSetting();
        
        // If Use_RollupBatch_for_Rollup_Field checkbox is true then execute the CustomRating_RollupBatch.
        if(globalSettingObj.Use_RollupBatch_for_Rollup_Field__c == true){
            Database.executeBatch(new CustomRating_RollupBatch(), 200);
        }else{
             // Enqueue the job to run CustomRating_Queueable class if Use_RollupBatch_for_Rollup_Field is false in custom setting
            System.enqueueJob(new CustomRating_Queueable(0));
        }
    }
}