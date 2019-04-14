@isTest
public with sharing class OpportunityHandlerTest {
   
   @TestSetup static void setup(){

        Id priceBookId = Test.getStandardPricebookId();

        Product2 p1 = new Product2( Name = 'Fast Charger', isActive = true);

        Product2 p2 = new Product2( Name = 'Installation', isActive = true);

        insert new Product2[]{p1, p2};

        PriceBookEntry pbe1 = new PriceBookEntry(Product2Id = p1.Id, Pricebook2Id = priceBookId, UnitPrice = 100, IsActive = true);

        PriceBookEntry pbe2 = new PriceBookEntry(Product2Id = p2.Id, Pricebook2Id = priceBookId, UnitPrice = 100, IsActive = true);

        insert new PriceBookEntry[]{pbe1, pbe2};
   }

   @isTest static void  newCustomerOpportunity() {
    
        Test.startTest(); {

            Opportunity o = new Opportunity(Name = 'New Motion', Type = 'New Customer', StageName = 'Prospecting', CloseDate = System.today());
            insert o;

            Account[] customers = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'PersonAccount'];

            System.assertEquals(1, customers.size(), 'New Customer Account should have been created');
            System.assertEquals(o.Name, customers[0].Name);

        } Test.stopTest();
   }


   @isTest static void  closeWonProductsInStock() {

       Test.startTest(); {

            Opportunity o = new Opportunity(Name = 'New Motion', Type = 'New Customer', StageName = 'Prospecting', CloseDate = System.today());
            insert o;

            Account[] customers = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'PersonAccount'];

            o.StageName = 'Closed Won';
            update o;

        } Test.stopTest();
   }

   @isTest static void  closeWonProductsOutOfStock() {

       Test.startTest(); {

            Opportunity o = new Opportunity(Name = 'New Motion', Type = 'New Customer', StageName = 'Prospecting', CloseDate = System.today());
            insert o;

            Account[] customers = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'PersonAccount'];

            PriceBookEntry[] pbes = [SELECT Id FROM PriceBookEntry];

            OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = o.Id, PricebookEntryId = pbes[0].Id, UnitPrice = 100, Quantity = 1);

            OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = o.Id, PricebookEntryId = pbes[1].Id, UnitPrice = 100, Quantity = 1);

            insert new OpportunityLineItem[]{oli1, oli2};

            Product2 p = [SELECT Id FROM Product2 LIMIT 1];

            p.OutOfStock__c = true;
            update p;

            o.StageName = 'Closed Won';
            for(Database.SaveResult dbr :Database.update(new Opportunity[]{o}, false)) {
                System.assertEquals(false, dbr.isSuccess(), 'Opportunity should not be available to close due to Product Out of Stock');
            }
        } Test.stopTest();
   }


   @isTest static void closeWonCreateOrder() {

       Test.startTest(); {

            Opportunity o = new Opportunity(Name = 'New Motion', Type = 'New Customer', StageName = 'Prospecting', CloseDate = System.today());
            insert o;

            Account[] customers = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'PersonAccount'];

            Order[] neworders = [SELECT Id FROM Order WHERE OpportunityId = :o.Id];

            System.assertEquals(0, neworders.size(), 'No orders should exist for this Open Opportunity');

            PriceBookEntry[] pbes = [SELECT Id FROM PriceBookEntry];

            OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = o.Id, PricebookEntryId = pbes[0].Id, UnitPrice = 100, Quantity = 1);

            OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = o.Id, PricebookEntryId = pbes[1].Id, UnitPrice = 100, Quantity = 1);

            insert new OpportunityLineItem[]{oli1, oli2};

            o.StageName = 'Closed Won';
            update o;

            neworders = [SELECT Id FROM Order WHERE OpportunityId = :o.Id];

            System.assertEquals(1, neworders.size(), 'Order should have been created for this opportunity');

        } Test.stopTest();
   }
}
