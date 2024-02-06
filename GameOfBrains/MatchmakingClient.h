//
//  MatchmakingClient.h
//  GameOfBrains
//
//  Created by Student on 27.11.15.
//  Copyright (c) 2015 Student. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@class MatchmakingClient;

@protocol MatchmakingClientDelegate <NSObject>

- (void)matchmakingClient:(MatchmakingClient *)client serverBecameAvailable:(NSString *)peerID;
- (void)matchmakingClient:(MatchmakingClient *)client serverBecameUnavailable:(NSString *)peerID;
- (void)matchmakingClient:(MatchmakingClient *)client didDisconnectFromServer:(NSString *)peerID;
- (void)matchmakingClientNoNetwork:(MatchmakingClient *)client;
- (void)matchmakingClient:(MatchmakingClient *)client didConnectToServer:(NSString *)peerID;

@end



@interface MatchmakingClient : NSObject <GKSessionDelegate>

@property (nonatomic, strong, readonly) NSArray *availableServers;
@property (nonatomic, strong, readonly) GKSession *session;

@property (nonatomic, weak) id <MatchmakingClientDelegate> delegate;

- (NSUInteger)availableServerCount;
- (NSString *)peerIDForAvailableServerAtIndex:(NSUInteger)index;
- (NSString *)displayNameForPeerID:(NSString *)peerID;

- (void)startSearchingForServersWithSessionID:(NSString *)sessionID;

- (void)connectToServerWithPeerID:(NSString *)peerID;

- (void)disconnectFromServer;


@end