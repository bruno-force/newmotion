
## Implementation

### Opportunity

#### Create Customers (PersonAccount) 
When New Opportunity is created of type 'New Customer' and it doesnt have any Account defined the system will create a Person Account Customer for the Opportunity with same name

#### Validate Product Availability on Close Won 
Before Opportunity gets 'Closed Won' the system will check that all related products are in stock
For this it will check on Product > Out of Stock Field and it will prevent the update if found at least one.

#### Create Orders 
When Opportunity gets 'Closed Won' Order and Order Line Items get created from Opportunity Product Definition

### Notification Service

It will send Visit Notification to all Opportunity Customers that have instalation date in the next 20 days and did not recieve the notification yet.

To prevent send multiple notification for the same installation a checkbox field was added to Opportunity (Notification Sent)

For Ducth speaking Customers a Dutch Template is set and for the rest an English Template will be used
This is checked under Language field in the Contact/Person Account

The system will use Salesforce Mass email solution that allows 5,000 emails per org per day sent to external email addresses.

https://help.salesforce.com/articleView?id=limitations_email_mass.htm&type=5

#### English Template
Name Visit_1555236786376, it will be sent to all customers that don't speak Dutch

#### Dutch Template
Name Visit_Dutch_1555239147669, it will be sent to all customers that speak Dutch

#### Scheduler Class

NotificationSchedule Class provide a method to automatically schedule the class to run once every hour

```java
NotificationSchedule.schedule();
```

And a method that allows to run the class immediately

```java
NotificationSchedule.run();
```
