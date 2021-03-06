//
//  SocketIO.m
//  SocketIO
//
//  Created by Patrick Perini on 6/13/14.
//
//

#import <XCTest/XCTest.h>
#import "SIOSocket.h"

@interface SocketIO : XCTestCase

@end

@implementation SocketIO

- (void)testConnectToLocalhost
{
    XCTestExpectation *connectionExpectation = [self expectationWithDescription: @"should connect to localhost"];
    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket)
    {
        XCTAssertNotNil(socket, @"socket could not connect to localhost");
        [connectionExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout: 10 handler: nil];
}

- (void)testFalse
{
    XCTestExpectation *falseExpectation = [self expectationWithDescription: @"should work with false"];
    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket)
    {
        XCTAssertNotNil(socket, @"socket could not connect to localhost");
        [socket on: @"false" callback: ^(id data)
        {
            XCTAssertFalse([data boolValue], @"response not false");
            [falseExpectation fulfill];
        }];

        [socket emit: @"false", nil];
    }];

    [self waitForExpectationsWithTimeout: 10 handler: nil];
}

- (void)testUTF8MultibyteCharacters
{
    XCTestExpectation *utf8MultibyteCharactersExpectation = [self expectationWithDescription: @"should work with utf8 multibyte characters"];
    NSArray *correctStrings = @[
        @"てすと",
        @"Я Б Г Д Ж Й",
        @"Ä ä Ü ü ß",
        @"utf8 — string",
        @"utf8 — string"
    ];

    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket)
    {
        XCTAssertNotNil(socket, @"socket could not connect to localhost");

        __block NSInteger numberOfCorrectStrings = 0;
        [socket on: @"takeUtf8" callback: ^(id data)
        {
            XCTAssertEqualObjects(data, correctStrings[numberOfCorrectStrings], @"%@ is not equal to %@", data, correctStrings);
            numberOfCorrectStrings++;

            if (numberOfCorrectStrings == [correctStrings count])
            {
                [utf8MultibyteCharactersExpectation fulfill];
            }
        }];

        [socket emit: @"getUtf8", nil];
    }];

    [self waitForExpectationsWithTimeout: 10 handler: nil];
}

- (void)testEmitDateAsString
{
    XCTestExpectation *stringExpectation = [self expectationWithDescription: @"should emit date as a string"];
    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket)
    {
        XCTAssertNotNil(socket, @"socket could not connect to localhost");
        [socket on: @"takeDate" callback: ^(id data)
        {
            XCTAssert([data isKindOfClass: [NSString class]], @"%@ is not a string", data);
            [stringExpectation fulfill];
        }];

        [socket emit: @"getDate", nil];
    }];

    [self waitForExpectationsWithTimeout: 10 handler: nil];
}

- (void)testEmitDateAsObject
{
    XCTestExpectation *stringExpectation = [self expectationWithDescription: @"should emit date as a string"];
    [SIOSocket socketWithHost: @"http://localhost:3000" response: ^(SIOSocket *socket)
    {
        XCTAssertNotNil(socket, @"socket could not connect to localhost");
        [socket on: @"takeDateObj" callback: ^(id data)
        {
            XCTAssert([data isKindOfClass: [NSDictionary class]], @"%@ is not a dictionary", data);
            XCTAssert([[data objectForKey: @"date"] isKindOfClass: [NSString class]], @"%@['date'] is not a string", data);

            [stringExpectation fulfill];
        }];

        [socket emit: @"getDateObj", nil];
    }];

    [self waitForExpectationsWithTimeout: 10 handler: nil];
}

@end
