/**********************************************************************************************************
* Class Name: CustomRating_TestDataFactory
* Author: KGS
*
* ============================================================================================================
* ============================================================================================================
* Purpose: This class generates/insert an sObject with all the required fields.
* ============================================================================================================
* ============================================================================================================
* History:
* VERSION     DATE                  INITIALS      DESCRIPTION/FEATURES ADDED
* 1.0         08-November-2021      KGS           Initial Development
***********************************************************************************************************/
public class CustomRating_TestDataFactory {
    
    public static CustomRating_Global_Setting__c createCustomRatingGlobalSetting() {
        
        CustomRating_Global_Setting__c globalSettingObj =  new CustomRating_Global_Setting__c();
        globalSettingObj.Object_Name__c = 'Account';
        globalSettingObj.Custom_Rating_Group_Field__c = 'Rating';
        globalSettingObj.Custom_Rating_1_Percentage__c=25;
        globalSettingObj.Custom_Rating_2_Percentage__c=25;
        globalSettingObj.Custom_Rating_3_Percentage__c=50;
        globalSettingObj.Custom_Rating_Field__c='Description';  
        globalSettingObj.Rating_Rollup_Sort_Order_Criteria__c = ' NumberOfEmployees Desc,CreatedDate Desc';
        globalSettingObj.Rating_Value_1__c='Hot';
        globalSettingObj.Rating_Value_2__c='Warm';
        globalSettingObj.Rating_Value_3__c='Cold';
        globalSettingObj.Rating_Criteria__c = 'Rating != null';
        globalSettingObj.Use_RollupBatch_for_Rollup_Field__c = true;         
        return globalSettingObj; 
    }
    
    public static Custom_Rating_Rollup_Batch_Settings__c createCustomRatingGlobalBatchSetting(){
        Custom_Rating_Rollup_Batch_Settings__c batchObj = new Custom_Rating_Rollup_Batch_Settings__c();
        batchObj.Aggregate_Result_Field__c = 'NumberOfEmployees';
        batchObj.Child_Object__c = 'Contact';
        batchObj.Rollup_Criteria__c = 'CreatedDate = LAST_N_DAYS:90';
        batchObj.Field_to_Aggregate__c = 'Id';
        batchObj.Parent_Object__c = 'Account';
        batchObj.Relationship_Field__c = 'AccountId';
        return batchObj;
    }    
    
    public static List<Account> createHotRatingAccount() {
        List<Account> accList = new List<Account>();
        for(Integer i=0 ; i< 12;i++){
            Account acc = new Account();
            acc.Name = 'Test Account' + i;
            acc.Rating = 'Hot';
            accList.add(acc);
        }
        return accList;
    }
    
    public static List<Account> createColdRatingAccount() {
        List<Account> accList = new List<Account>();
        for(Integer i=0 ; i< 12;i++){
            Account acc = new Account();
            acc.Name = 'Test Account' + i;
            acc.Rating = 'Cold';
            accList.add(acc);
        }
        return accList;
    }
    
    public static List<Contact> createContact(List<Account> accList){
        List<Contact> conList = new List<Contact>();
        for(Account acc :accList){
            Contact con = new Contact();
            con.LastName = 'Test Contact' + acc.Name;
            con.AccountId = acc.Id;
            conList.add(con);
        }        
        return conList; 
    }
    
}