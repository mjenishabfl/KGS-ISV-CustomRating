/**********************************************************************************************************
* Class Name: CustomRating_RollupBatchTest
* Author: KGS
*
* ============================================================================================================
* ============================================================================================================
* Purpose: Test class to test the functionality for 'CustomRating_RollupBatch' apex class.
* ============================================================================================================
* ============================================================================================================
* History:
* VERSION     DATE                  INITIALS      DESCRIPTION/FEATURES ADDED
* 1.0         08-November-2021      KGS           Initial Development
***********************************************************************************************************/
@isTest
Public class CustomRating_RollupBatchTest{
    
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
    
     @isTest
    public static void CustomRatingWithRollupBatchTest() {        
        Test.startTest();
        Database.executeBatch(new CustomRating_RollupBatch(),200);
        Test.stopTest();        
        
        List<Account> accList = [SELECT Id,Description FROM Account WHERE Rating = 'Hot'];
        System.debug('accList==>'+accList);
        for(Account acc : accList){
            System.assert(String.isNotBlank(acc.Description));
        }  
    }   
}