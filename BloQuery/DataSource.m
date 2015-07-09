//
//  DataSource.m
//  BloQuery
//
//  Created by Andrew Carvajal on 6/18/15.
//  Copyright (c) 2015 andrewcar. All rights reserved.
//

#import "DataSource.h"
#import <Parse/Parse.h>

@implementation DataSource

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
    }
    return self;
}

- (void)postQuestion:(NSString *)questionText withSuccess:(void (^)(BOOL succeeded))successBlock {
    PFObject *question = [PFObject objectWithClassName:@"Question"];
    
    question[@"text"] = questionText;
    
    // set asked by
    PFRelation *askedByRelation = [question relationForKey:@"askedBy"];
    [askedByRelation addObject:[PFUser currentUser]];

    [question saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (successBlock) {
            successBlock(succeeded);
        }
    }];
}

- (void)postAnswer:(NSString *)answerText withSuccess:(void (^)(BOOL succeeded))successBlock {
    PFObject *answer = [PFObject objectWithClassName:@"Answer"];
    
    answer[@"text"] = answerText;
    

    
    PFRelation *answerRelation = [self.question relationForKey:@"Answers"];
    [answerRelation addObject:answer];
    
    [answer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self.question saveInBackgroundWithBlock:^(BOOL succeded, NSError *error) {
            if (successBlock) {
                successBlock(succeded);
                NSLog(@"question saved");
            }
        }];
    }];
    
    // set replied by to current user
    PFRelation *repliedByRelation = [answer relationForKey:@"repliedBy"];
    [repliedByRelation addObject:[PFUser currentUser]];
    
    [answer saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (successBlock) {
            successBlock(succeeded);
        }
    }];
}
- (void)populateListOfQuestions:(void (^)(NSArray *questions))successBlock {
    PFQuery *questionQuery = [PFQuery queryWithClassName:@"Question"];
    
    [questionQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.listOfQuestions = [objects mutableCopy];
            if (successBlock) {
                successBlock(self.listOfQuestions);
            }
        }
    }];
}

- (void)answersForQuestion:(PFObject *)question withSuccess:(void (^)(NSArray *))successBlock {
    PFRelation *answersRelation = [question relationForKey:@"Answers"];

    [[answersRelation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (successBlock) {
                successBlock(objects);
            }
        }
    }];
}

@end
