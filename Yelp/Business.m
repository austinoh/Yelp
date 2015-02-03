//
//  Business.m
//  Yelp
//
//  Created by Austin Oh on 1/28/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "Business.h"

@implementation Business

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self ) {
        NSArray *categories = dictionary[@"categories"];
        NSMutableArray *categoryNames = [NSMutableArray array];
        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, bool *stop) {
            [categoryNames addObject:obj[0]];
        }];
        
        self.categories = [categoryNames componentsJoinedByString:@", "];
        self.businessName = dictionary[@"name"];
        self.imageUrl = dictionary[@"image_url"];

        // no guaranted that location.address and/or neighborhoods exist
        NSMutableArray *address = [NSMutableArray array];
        NSArray *street = [dictionary valueForKeyPath:@"location.address"];
        if (street.count > 0) {
            [address addObject:street[0]];
        }
        
        NSArray *neighborhood = [dictionary valueForKeyPath:@"location.neighborhoods"];
        if (neighborhood.count > 0) {
            [address addObject:neighborhood[0]];
        }
        self.address = [address componentsJoinedByString:@", "];
        
        self.numReviews = [dictionary[@"review_count"] integerValue];
        self.ratingImageUrl = dictionary[@"rating_img_url"];
        float milesPerMeter = 0.000621371;
        self.distance = [dictionary[@"distance"] integerValue] * milesPerMeter;
    }
    
    return self;
}

+ (NSArray *)businessesWithDictionaries:(NSArray *)dictionaries
{
    NSMutableArray *businesses = [NSMutableArray array];
    
    for (NSDictionary *dictionary in dictionaries) {
        Business *business = [[Business alloc] initWithDictionary:dictionary];
        
        [businesses addObject:business];
    }
    
    return businesses;
}

@end
