public with sharing class OpportunityService {
    
    public static final Id PERSON_ACCOUNT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
    public static final String OUT_OF_STOCK_ERROR = 'Unable to close this Opportunity, {0} is Out of Stock.';

    public static void createNewCustomers(Opportunity[] newCustomerOpptys) {
        
        Map<Integer, Account> newCustomers = new Map<Integer, Account>();

        for(Integer i = 0; i < newCustomerOpptys.size(); i++) {
            Opportunity o = newCustomerOpptys[i];
            String firstName, lastName;
            if(o.Name.contains(' ')) {
                String[] name = o.Name.split(' ');
                firstName = name[0];
                lastName = name[1];
            } else {
                lastName = o.Name;
            }

            newCustomers.put(i, new Account(FirstName = firstName, LastName = lastName, RecordTypeId = PERSON_ACCOUNT));
        }

        insert newCustomers.values();

        for(Integer i: newCustomers.keySet()) {
            Account pa = newCustomers.get(i);
            newCustomerOpptys[i].AccountId = pa.Id;
        }
    }

    public static void createOrders(Opportunity[] wonOpptys) {
        
        Map<Id, Order> newOrders = new Map<Id, Order>();
        OrderItem[] newOrderItems = new OrderItem[]{};

        // Generate Orders
        for(Opportunity o: wonOpptys) {
            if(o.AccountId != null) {
                newOrders.put(o.Id, new Order(
                    OpportunityId = o.Id,
                    AccountId = o.AccountId,
                    EffectiveDate = o.CloseDate,
                    Status= 'Draft',
                    Pricebook2Id = o.Pricebook2Id
                ));
            }
        }
        
        // Insert Orders
        if(newOrders.values().size() > 0) insert newOrders.values();

        // Generate Order Items from Product Line Items
        for(OpportunityLineItem opptyProduct: getProductLineItems(newOrders.keySet())) {

            Id orderId = newOrders.get(opptyProduct.OpportunityId).Id;

            newOrderItems.add(new OrderItem(
                OrderId = orderId,
                Quantity = opptyProduct.Quantity,
                PricebookEntryId = opptyProduct.PricebookEntryId,
                UnitPrice = opptyProduct.UnitPrice
            ));   
        }

        // Insert Order Items
        if(newOrderItems.size() > 0) insert newOrderItems;
    }

    public static void validateProductAvailability(Opportunity[] wonOpptys) {

        Set<Id> wonOpttyIds = new Set<Id>();

        for(Opportunity o: wonOpptys) wonOpttyIds.add(o.Id);

        for(OpportunityLineItem opptyProduct: getProductLineItems(wonOpttyIds)) {
            if(opptyProduct.Product2.OutOfStock__c) {
                Trigger.newMap.get(opptyProduct.OpportunityId)
                .addError(String.format(OUT_OF_STOCK_ERROR, new String[]{opptyProduct.Product2.Name}));
            }
        }
    }

    /**
    * Repositories
    */

    public static OpportunityLineItem[] getProductLineItems(Set<Id> opptyIds) {
        return [
            SELECT Id, Name, ProductCode, Quantity, PricebookEntryId, UnitPrice, OpportunityId, Product2.OutOfStock__c, Product2.Name
            FROM OpportunityLineItem 
            WHERE OpportunityId IN: opptyIds
        ];
    }
}
