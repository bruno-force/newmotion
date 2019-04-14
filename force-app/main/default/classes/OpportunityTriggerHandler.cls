public with sharing class OpportunityTriggerHandler {
    
    public static final String STAGE_WON = 'Closed Won';
    public static final String NEW_CUSTOMER = 'New Customer';

    /**
    *   Before Insert 
    *   If Opportunity is "New Customer" and there is no Account defined create a new Person Account
    */

    public static void beforeInsert() {

        Opportunity[] newCustomers = new Opportunity[]{};

        for(Opportunity oppty: (Opportunity[])Trigger.new) {
	        if(oppty.Type == NEW_CUSTOMER && oppty.AccountId == null && hasChanged(oppty, 'Type')){
                newCustomers.add(oppty);
            }
        }

        OpportunityService.createNewCustomers(newCustomers);
    }

    /**
    *   Before Update | Validate Product Availability Before Close Won
    */

    public static void beforeUpdate() {
        
        Opportunity[] wonOpptys = new Opportunity[]{};

        for(Opportunity oppty: (Opportunity[])Trigger.new) {
	        if(oppty.StageName == STAGE_WON && hasChanged(oppty, 'StageName')){
                wonOpptys.add(oppty);
            }
        }

        OpportunityService.validateProductAvailability(wonOpptys);
    }

    /**
    *   After Update 
    *   Create Order from Won Opportunities
    */

    public static void afterUpdate() {

        Opportunity[] wonOpptys = new Opportunity[]{};

        for(Opportunity oppty: (Opportunity[])Trigger.new) {
	        if(oppty.StageName == STAGE_WON && hasChanged(oppty, 'StageName')){
                wonOpptys.add(oppty);
            }
        }

        OpportunityService.createOrders(wonOpptys);
    }

    /**
    * Utils
    */

    public static Boolean hasChanged(Sobject o, String fieldName) {
        return Trigger.isInsert || (o.get(fieldName) != Trigger.oldMap.get((Id)o.get('Id')).get(fieldName));
    }
}
