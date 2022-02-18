/**********************************************************************************************************
* Class Name: CustomRating_Utility
* Author: KGS
*
* ============================================================================================================
* ============================================================================================================
* Purpose: This class contains generic methods which are used for CustomRating batch classes.
* ============================================================================================================
* ============================================================================================================
* History:
* VERSION     DATE                  INITIALS      DESCRIPTION/FEATURES ADDED
* 1.0         01-November-2021      KGS           Initial Development
***********************************************************************************************************/
public class CustomRating_Utility {
    
    public static final String SELECT_STR = 'SELECT Id, ';
    public static final String SELECT_COUNT_STR = 'SELECT count(Id)';
    public static final String FROM_STR = ' FROM ';
    public static final String WHERE_STR= ' WHERE ';
    public static final String ORDER_BY_STR= ' ORDER BY ';
    public static final String CreatedDate_Desc_STR=',CreatedDate Desc';
    public static final String GROUP_BY_STR = ' GROUP BY ';
    
    
    public static CustomRating_Global_Setting__c getCustomRatingGlobalSetting(){
        CustomRating_Global_Setting__c globalSettingObj = CustomRating_Global_Setting__c.getInstance();
        return globalSettingObj;
    }
    
    // This method counts the total number of records which satisfies the criteria.
    public static List<AggregateResult> fetchSobjectCount(CustomRating_Global_Setting__c globalSettingObj,String ratingField){        
        String query = SELECT_COUNT_STR + FROM_STR;
        query += globalSettingObj.Object_Name__c + WHERE_STR;
        query += globalSettingObj.Custom_Rating_Group_Field__c + ' = ' + '\''+ratingField+'\'';
        if(globalSettingObj.Rating_Criteria__c != null){
            query += ' AND ' + globalSettingObj.Rating_Criteria__c;
        } 
        System.debug('query==>'+query);
        List<AggregateResult> aggregateResultList = Database.query(query);        
        return aggregateResultList;
    }
    
    // Calculate count of records based on percentage
    public static Integer calculateRatingCounts(Integer listSize,Decimal tierPercentage){
        Decimal ratingValue = Double.valueOf(listSize * tierPercentage)/100;
        Integer ratingCount = ratingValue.round(System.RoundingMode.UP).intValue();        
        return ratingCount;
    }
    
    // Fetch the group field values
    public static List<String> getGroupFieldValues(){
        CustomRating_Global_Setting__c globalSettingObj = getCustomRatingGlobalSetting();        
        List<String> pickListValuesList= new List<String>();
        try{
            String strObjectName = globalSettingObj.Object_Name__c;
            String strPicklistField = globalSettingObj.Custom_Rating_Group_Field__c;            
            Map<String, String> mapPickListValues = new Map<String, String>();
            Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
            Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
            Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
            List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
            for (Schema.PicklistEntry objPickList : lstPickListValues) {
                pickListValuesList.add(objPickList.getValue());
            }
        }Catch(Exception e){
            System.debug('exception==>'+e.getMessage());
        }
        
        return pickListValuesList;
    }
    
    // Get the child relationship name based on parent object and child object name.
    public static string getChildRelationshipName(Custom_Rating_Rollup_Batch_Settings__c customRatingSetting){
        String parentObject = customRatingSetting.Parent_Object__c;
        String childObject = customRatingSetting.Child_Object__c;
        String childRelationshipName;
        
        Schema.SObjectType parentSobjectType = Schema.getGlobalDescribe().get(parentObject);
        Schema.SObjectType childSobjectType = Schema.getGlobalDescribe().get(childObject);
        
        Schema.DescribeSObjectResult objDescribeSobject = parentSobjectType.getDescribe();
        for (ChildRelationship relation : objDescribeSobject.getChildRelationships()){
            if (relation.getChildSObject() == childSobjectType){
                String relationShipFieldName = string.valueof(relation.getField());
                if(customRatingSetting.Relationship_Field__c.equals(relationShipFieldName)){
                    childRelationshipName = relation.getRelationshipName();
                }                
            }
        }
        return childRelationshipName;
    }    
    
    // This method fetches the count of child object with parent Id.
    public static List<AggregateResult> fetchChildObjectCounts(Custom_Rating_Rollup_Batch_Settings__c customRatingSetting,Set<String> parentIdSet){
        
        String query = SELECT_COUNT_STR + ', ';
        query += customRatingSetting.Relationship_Field__c;
        query += FROM_STR + customRatingSetting.Child_Object__c;
        query += WHERE_STR + customRatingSetting.Relationship_Field__c + ' IN ';
        query += ':parentIdSet ';
        if(customRatingSetting.Rollup_Criteria__c !=null){
            query += ' AND ';
            query += customRatingSetting.Rollup_Criteria__c + ' ';
        }
        
        query +=  GROUP_BY_STR + customRatingSetting.Relationship_Field__c;
        
        System.debug('query==>'+query);
        List<AggregateResult> aggregateResultList = Database.query(query);        
        return aggregateResultList;
    }
}