global with sharing class NotificationSchedule implements Schedulable {

    // Template Definition
    public static final String VISIT_TEMPLATE = 'Visit_1555236786376';
    public static final String VISIT_TEMPLATE_DUTCH = 'Visit_Dutch_1555239147669';
    
    // Easy Schedule
    global void schedule(){
        // Run every hour
        System.schedule('Notification Cron Job', '0 0 * * * ?', new NotificationSchedule());
    }

    // Default Schedulable Class Execute
    global void execute(SchedulableContext sc) { run(); }

    /**
    *   Utils
    */

    global static void run(){

        // Pick Opportunities for Notification
        Opportunity[] opptysForNotification = getOpptysForNotification();
        Id[] customersForNotification = new Id[]{};

        Map<String, Id[]> templateCustomerMap = new Map<String, Id[]>();
        Map<Id, Contact> personAccountContactMap = new Map<Id, Contact>();

        // Collect Customer Info
        for(Opportunity o: opptysForNotification) {
            customersForNotification.add(o.AccountId);
            o.NotificationSent__c = true;
        }

        // Map Customer to Contact (Person Account)
        for(Contact c: getPersonAccountContacts(customersForNotification)) {
            personAccountContactMap.put(c.AccountId, c);
        }

        // Build Notifications
        for(Opportunity o: opptysForNotification) {

            // Get Contact related to Customer
            Contact c = personAccountContactMap.get(o.AccountId);

            // Pick Template based on contact language
            String templateName = (c.Language__c == 'Dutch')? VISIT_TEMPLATE_DUTCH: VISIT_TEMPLATE;

            if(!templateCustomerMap.containsKey(templateName)) templateCustomerMap.put(templateName, new Id[]{});

            // Build Template > Recipients Map
            templateCustomerMap.get(templateName).add(c.Id);
        }

        // Send Notifications | Template > Recipients
        sendNotification(templateCustomerMap);

        // Update Opptys Sent Notification Field
        update opptysForNotification;
    }

    global static void sendNotification(Map<String, Id[]> templateCustomerMap) {

        Messaging.MassEmailMessage[] notifications = new Messaging.MassEmailMessage[]{};
        EmailTemplate[] templates = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName IN :templateCustomerMap.keySet()];

        // Build Mass Email Set-up for Each Template
        for(EmailTemplate template: templates) {
            Messaging.MassEmailMessage mail = new Messaging.MassEmailMessage();
            mail.setTargetObjectIds(templateCustomerMap.get(template.DeveloperName));
            mail.setSenderDisplayName('New Motion Installation Team');
            mail.setTemplateId(template.id);
            notifications.add(mail);
        }

        // Send
        Messaging.sendEmail(notifications);
    }

    /**
    * Repositories
    */

    private static Opportunity[] getOpptysForNotification() {
        return [
            SELECT Id, Name, InstallationDate__c, NotificationSent__c, AccountId
            FROM Opportunity
            WHERE NotificationSent__c = false
            AND InstallationDate__c <= NEXT_N_DAYS:20
            AND AccountId != null
            LIMIT 50000
        ];
    }

    public static Contact[] getPersonAccountContacts(Id[] customerIds) {
        return [
            SELECT Id, Name, Email, Language__c, AccountId, Account.Name, Account.PersonEmail
            FROM Contact 
            WHERE AccountId IN: customerIds
        ];
    }
}
