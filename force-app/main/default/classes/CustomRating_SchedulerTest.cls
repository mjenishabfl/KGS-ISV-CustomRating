/**********************************************************************************************************
* Class Name: CustomRating_SchedulerTest
* Author: KGS
*
* ============================================================================================================
* ============================================================================================================
* Purpose: Test class to test the functionality for 'CustomRating_Scheduler' apex class.
* ============================================================================================================
* ============================================================================================================
* History:
* VERSION     DATE                  INITIALS      DESCRIPTION/FEATURES ADDED
* 1.0         08-November-2021      KGS           Initial Development
***********************************************************************************************************/
@isTest
public class CustomRating_SchedulerTest {

    @testSetup 
    public static void setup(){        
        //Creating "CustomRating Global Setting" object
        CustomRating_Global_Setting__c CRGScOne = CustomRating_TestDataFactory.createCustomRatingGlobalSetting();
        insert CRGScOne;
        
        Custom_Rating_Rollup_Batch_Settings__c batchObj = CustomRating_TestDataFactory.createCustomRatingGlobalBatchSetting();
        insert batchObj;
        
         //Creating "Account" object
        List<Account> accountHotRatingList = CustomRating_TestDataFactory.createHotRatingAccount(); 
        insert accountHotRatingList; 
        
        List<Contact> conList = CustomRating_TestDataFactory.createContact(accountHotRatingList);
        insert conList;
    }
    
    // Test the functionality with Rollup Batch functionality
    @isTest
    public static void CustomRatingWithRollupBatchTest() {        
        Test.startTest();
        CustomRating_Scheduler schedularObj = new CustomRating_Scheduler();   
        String cron = '0 0 23 * * ?';        
        system.schedule('Test Sched', cron, schedularObj);
        Test.stopTest();        
    }     
    
    // Test the functionality without Rollup Batch functionality
    @isTest
    public static void CustomRatingWithoutRollupBatchTest() {
        CustomRating_Global_Setting__c globalSetting = [Select Id,
                                                         Use_RollupBatch_for_Rollup_Field__c
                                                         From CustomRating_Global_Setting__c Limit 1];
        if(globalSetting != null){
            globalSetting.Use_RollupBatch_for_Rollup_Field__c = false;
            update globalSetting;
        }
        
        Test.startTest();
        CustomRating_Scheduler schedularObj = new CustomRating_Scheduler();   
        String cron = '0 0 23 * * ?';        
        system.schedule('Test Sched', cron, schedularObj);
        Test.stopTest();  
    }     
    
}