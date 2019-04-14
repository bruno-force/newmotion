@isTest
public with sharing class NotificationServiceTest {
    
    @TestSetup static void setup() {
        
        Id priceBookId = Test.getStandardPricebookId();

        Product2 p1 = new Product2( Name = 'Fast Charger', isActive = true);

        Product2 p2 = new Product2( Name = 'Installation', isActive = true);

        insert new Product2[]{p1, p2};

        PriceBookEntry pbe1 = new PriceBookEntry(Product2Id = p1.Id, Pricebook2Id = priceBookId, UnitPrice = 100, IsActive = true);

        PriceBookEntry pbe2 = new PriceBookEntry(Product2Id = p2.Id, Pricebook2Id = priceBookId, UnitPrice = 100, IsActive = true);
       
        insert new PriceBookEntry[]{pbe1, pbe2};

        Opportunity o = new Opportunity(Name = 'New Motion', Type = 'New Customer', StageName = 'Prospecting', CloseDate = System.today(), InstallationDate__c = System.today());
        insert o;
    }

    @isTest static void sendNotifications() {

        Test.startTest(); {

            Account customer = [SELECT Id, (SELECT Id FROM Tasks) FROM Account WHERE Name = 'New Motion' LIMIT 1];

            System.assertEquals(0, customer.Tasks.size());

            NotificationSchedule.run();

        } Test.stopTest();
    }


    @isTest static void scheduleCLass() {

        Test.startTest(); {

            NotificationSchedule.schedule();

        } Test.stopTest();
    }
}