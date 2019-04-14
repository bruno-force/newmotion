trigger Opportunity on Opportunity (before insert, before update, after insert, after update) {
    if(Trigger.isBefore && Trigger.isInsert){
        OpportunityTriggerHandler.beforeInsert();
    } else if(Trigger.isBefore && Trigger.isUpdate){
        OpportunityTriggerHandler.beforeUpdate();
    } else if(Trigger.isAfter && Trigger.isInsert){
        //OpportunityTriggerHandler.afterInsert();
    } else if(Trigger.isAfter && Trigger.isUpdate){
        OpportunityTriggerHandler.afterUpdate();
    }
}