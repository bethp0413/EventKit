#import "Kiwi.h"
#import <EventKit/EventKit.h>

SPEC_BEGIN(EventKitSpec)

describe(@"EventKit", ^{
	
	__block EKEventStore *sut;
	
	beforeAll(^{
		
		sut = [[EKEventStore alloc] init];
		[sut requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
			NSLog(@"Access %@", granted ? @"Granted" : @"Denied");
		}];
		
	});

	afterAll(^{
	
        NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-60];
		NSDate *endDate = [NSDate distantFuture];
		
		NSPredicate *predicate = [sut predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
		
		NSArray *events = [sut eventsMatchingPredicate:predicate];
		
		if (events && events.count > 0) {
			
			NSLog(@"Deleting Events...");
			
			[events enumerateObjectsUsingBlock:^(EKEvent *event, NSUInteger idx, BOOL *stop) {
		
				NSLog(@"Removing Event: %@", event);
				NSError *error;
				if ( ! [sut removeEvent:event span:EKSpanFutureEvents commit:NO error:&error]) {
					
					NSLog(@"Error in delete: %@", error);
					
				}
				
			}];
			
			[sut commit:NULL];
		
		} else {
			
			NSLog(@"No Events to Delete.");
		}
		
	});
	
	it(@"should exist", ^{
		
        [sut shouldNotBeNil];
        
    });
	
	it(@"should have calendars", ^{
		
        NSArray *calendars = [sut calendarsForEntityType:EKEntityTypeEvent];
		
		[[calendars should] haveAtLeast:1];
		
		NSLog(@"%@", calendars);
        
    });

	it(@"should have some default events (birthdays)", ^{
		
        NSDate *startDate = [NSDate date];
		NSDate *endDate = [NSDate distantFuture];
		
		NSPredicate *predicate = [sut predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
		
		NSArray *events = [sut eventsMatchingPredicate:predicate];
		
		[[events should] haveAtLeast:1];
		
		NSLog(@"%@", predicate);
		NSLog(@"%@", events);
        
    });
	
	context(@"create an event", ^{
		
		__block EKEvent *event;
		NSString *eventTitle = @"Test Event";
		__block NSDate *startDate = [NSDate date];
		__block NSDate *endDate = [NSDate date];
		__block NSArray *events;
		
		beforeEach(^{
			
			event = [EKEvent eventWithEventStore: sut];
			event.calendar = [sut defaultCalendarForNewEvents];
			event.title = eventTitle;
			event.startDate = startDate;
			event.endDate = endDate;
			
			NSLog(@"%@", event);
			NSError *error;
			if ( ! [sut saveEvent:event span:EKSpanThisEvent commit:YES error:&error]) {
				
				NSLog(@"Error: %@", error);
			}
			
			startDate = [NSDate dateWithTimeIntervalSinceNow:-5];
			endDate = [NSDate dateWithTimeIntervalSinceNow:5];
			NSPredicate *predicate = [sut predicateForEventsWithStartDate:startDate endDate:endDate calendars:nil];
			
			events = [sut eventsMatchingPredicate:predicate];
			
		});
		
		it(@"should have one event", ^{
			
			[[events should] haveCountOf:1];
			
			NSLog(@"%@", events);
			
		});

		

		
	});
	


});

SPEC_END


