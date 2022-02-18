/**********************************************************************************************************
* Class Name: CustomRating_UtilityTest
* Author: KGS
*
* ============================================================================================================
* ============================================================================================================
* Purpose: Test class to test the functionality for 'CustomRating_Batch' apex class.
* ============================================================================================================
* ============================================================================================================
* History:
* VERSION     DATE                  INITIALS      DESCRIPTION/FEATURES ADDED
* 1.0         01-November-2021      KGS           Initial Development
***********************************************************************************************************/
@isTest
public class CustomRating_BatchTest {

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
        Database.executeBatch(new CustomRating_Batch('Hot',Null,0),200);            
        Test.stopTest();
        
        List<Account> accList = [SELECT Id,Description FROM Account WHERE Rating = 'Hot'];
        System.debug('accList==>'+accList);
        for(Account acc : accList){
            System.assert(String.isNotBlank(acc.Description));
        }  
    }
}