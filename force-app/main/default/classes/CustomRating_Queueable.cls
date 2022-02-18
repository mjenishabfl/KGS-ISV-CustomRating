/**********************************************************************************************************
* Class Name: CustomRating_Queueable
* Author: KGS
*
* ============================================================================================================
* ============================================================================================================
* Purpose: This queuable class runs the CustomRating_Batch for all group field values.
* ============================================================================================================
* ============================================================================================================
* History:
* VERSION     DATE                  INITIALS      DESCRIPTION/FEATURES ADDED
* 1.0         03-November-2021      KGS           Initial Development
***********************************************************************************************************/
public class CustomRating_Queueable implements Queueable{

    public Integer iterationCount;    
    public CustomRating_Queueable (Integer iterationCount){
        this.iterationCount = iterationCount;
    }    
    
    public void execute(QueueableContext context) {
        List<String> groupFieldValuesList = CustomRating_Utility.getGroupFieldValues();
        if(iterationCount < groupFieldValuesList.size()){
            Database.executeBatch(new CustomRating_Batch(groupFieldValuesList[iterationCount],context.getJobId(),iterationCount),200);            
        }        
    }
}