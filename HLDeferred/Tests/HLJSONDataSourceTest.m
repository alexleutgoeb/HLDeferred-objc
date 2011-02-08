//
//  HLJSONDataSourceTest.m
//  HLDeferred
//
//  Copyright 2011 HeavyLifters Network Ltd.. All rights reserved.
//  See included LICENSE file (MIT) for licensing information.
//

#import "HLJSONDataSource.h"

@interface HLJSONDataSourceTest : GHAsyncTestCase
@end

@implementation HLJSONDataSourceTest

- (void) testSimple
{
	[self prepare];
	
	HLJSONDataSource *ds = [[HLJSONDataSource alloc] initWithURLString: @"http://api.twitter.com/1/statuses/public_timeline.json"];
	HLDeferred *d = [ds requestStartOnQueue: [NSOperationQueue mainQueue]];
	[ds release]; ds = nil;
	
	__block BOOL success = NO;
	
	[d then: ^(id result) {
		success = YES;
		GHAssertTrue([result isKindOfClass: [NSArray class]], @"expected NSArray");
		[self notify: kGHUnitWaitStatusSuccess forSelector: @selector(testSimple)];
		return result;
	} fail: ^(HLFailure *failure) {
		[self notify: kGHUnitWaitStatusFailure forSelector: @selector(testSimple)];
		return failure;
	}];
	[self waitForStatus: kGHUnitWaitStatusSuccess timeout: 5.0];
	GHAssertTrue(success, @"callback didn't run");	
}

- (void) testFail
{
	[self prepare];
	
	HLJSONDataSource *ds = [[HLJSONDataSource alloc] initWithURLString: @"http://www.google.com/"];
	HLDeferred *d = [ds requestStartOnQueue: [NSOperationQueue mainQueue]];
	[ds release]; ds = nil;
	
	__block BOOL success = NO;
	
	[d then: ^(id result) {
		[self notify: kGHUnitWaitStatusFailure forSelector: @selector(testFail)];
		return result;
	} fail: ^(HLFailure *failure) {
		success = YES;
		[self notify: kGHUnitWaitStatusSuccess forSelector: @selector(testFail)];
		return failure;
	}];
	[self waitForStatus: kGHUnitWaitStatusSuccess timeout: 5.0];
	GHAssertTrue(success, @"errback didn't run");	
}

@end