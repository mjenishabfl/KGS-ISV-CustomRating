/**********************************************************************************************************
* Class Name: CustomRating_QueueableTest
* Author: KGS
*
* ============================================================================================================
* ============================================================================================================
* Purpose: Test class to test the functionality for 'CustomRating_Queueable' apex class.
* ============================================================================================================
* ============================================================================================================
* History:
* VERSION     DATE                  INITIALS      DESCRIPTION/FEATURES ADDED
* 1.0         08-November-2021      KGS           Initial Development
***********************************************************************************************************/
@isTest
public class CustomRating_QueueableTest {
    
    @testSetup
    public static void setup(){        
        //Creating "CustomRating Global Setting" object
        CustomRating_Global_Setting__c CRGScOne = CustomRating_TestDataFactory.createCustomRatingGlobalSetting();
        insert CRGScOne;
        
        //Creating "Account" object
        List<Account> accountHotRatingList = CustomRating_TestDataFactory.createHotRatingAccount(); 
        insert accountHotRatingList;        
    }
    
    @isTest
    public static void CustomRatingBatchTest() {           
        Test.startTest();
        System.enqueueJob(new CustomRating_Queueable(0));
        Test.stopTest();
        
        List<Account> accList = [SELECT Id,Description FROM Account WHERE Rating = 'Hot'];
        System.debug('accList==>'+accList);
        for(Account acc : accList){
            System.assert(String.isNotBlank(acc.Description));
        }        
    }    
  
}