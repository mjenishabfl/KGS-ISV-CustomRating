/**********************************************************************************************************
* Class Name: CustomRating_UtilityTest
* Author: KGS
*
* ============================================================================================================
* ============================================================================================================
* Purpose: Test class to test the functionality for 'CustomRating_Utility' apex class.
* ============================================================================================================
* ============================================================================================================
* History:
* VERSION     DATE                  INITIALS      DESCRIPTION/FEATURES ADDED
* 1.0         01-November-2021      KGS           Initial Development
***********************************************************************************************************/
@isTest
public class CustomRating_UtilityTest {
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
    Public static void fetchSobjectCountTest(){
        CustomRating_Global_Setting__c globalSetting = [Select Id,
                                                        Object_Name__c,
                                                        Custom_Rating_Group_Field__c,
                                                        Rating_Criteria__c
                                                        From CustomRating_Global_Setting__c Limit 1];
        Test.startTest();
        List<AggregateResult> sObjList = CustomRating_Utility.fetchSobjectCount(globalSetting,'Hot');  
        Test.stopTest(); 
        
        Integer listSize = Integer.valueOf(sObjList[0].get('expr0'));
        System.assert(listSize !=0);
    }
    
    @isTest
    Public static void getCustomRatingGlobalSettingTest(){
        Test.startTest();
        CustomRating_Utility.getCustomRatingGlobalSetting();
        Test.stopTest(); 
    }
    
    @isTest
    Public static void calculateRatingCountsTest(){
        Integer count;
        Test.startTest();
        count = CustomRating_Utility.calculateRatingCounts(3, 25);
        Test.stopTest(); 
        System.assert(count !=0);
    }
    
    @isTest
    Public static void getGroupFieldValuesTest(){
        List<String> pickListValuesList = new List<String>();
        Test.startTest();
        pickListValuesList = CustomRating_Utility.getGroupFieldValues();
        Test.stopTest(); 
        System.assert(!pickListValuesList.isEmpty());
    }
    
    @isTest
    Public static void getChildRelationshipNameTest(){
        String childRelationshipName;
        Custom_Rating_Rollup_Batch_Settings__c globalBatchSetting = [Select Id,
                                                                     Parent_Object__c,
                                                                     Child_Object__c,
                                                                     Relationship_Field__c
                                                                     From Custom_Rating_Rollup_Batch_Settings__c 
                                                                     Limit 1];
        Test.startTest();
        childRelationshipName = CustomRating_Utility.getChildRelationshipName(globalBatchSetting);
        Test.stopTest(); 
        System.assertEquals('Contacts', childRelationshipName);
    }
}