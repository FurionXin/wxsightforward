#import "WXsightforward.h"
static WCTimeLineViewController *WCTimelineVC = nil;
%hook WCContentItemViewTemplateNewSight
%new
- (id)SLSightDataItem
{
    id responder = self;
    MMTableViewCell *SightCell = nil;
    MMTableView *SightTableView = nil;
    while (![responder isKindOfClass:NSClassFromString(@"WCTimeLineViewController")])
    {
        if ([responder isKindOfClass:NSClassFromString(@"MMTableViewCell")]){
            SightCell = responder;
        }
        else if ([responder isKindOfClass:NSClassFromString(@"MMTableView")]){
            SightTableView = responder;
        }
        responder = [responder nextResponder];
        %log(responder);
    }
    WCTimelineVC = responder;
    if (!(SightCell&&SightTableView&&WCTimelineVC))
    {
        NSLog(@"iOSRE: Failed to get video object.");
        return nil;
    }
    NSIndexPath *indexPath = [SightTableView indexPathForCell:SightCell];
    int itemIndex = [WCTimelineVC calcDataItemIndex:[indexPath section]];
    WCFacade *facade = [(MMServiceCenter *)[%c(MMServiceCenter) defaultCenter] getService: [%c(WCFacade) class]];
    WCDataItem *dataItem = [facade getTimelineDataItemOfIndex:itemIndex];
    WCContentItem *contentItem = dataItem.contentObj;
    WCMediaItem *mediaItem = [contentItem.mediaList count] != 0 ? (contentItem.mediaList)[0] : nil;
    %log((NSString *)@"get mediaItem",mediaItem);
    return mediaItem;
}

%new
- (void)SLSightSaveToDisk
{
    %log((NSString *)@"iOSRE Welcome SaveToDisk!");
    NSString *localPath = [[self SLSightDataItem] pathForSightData];
    %log((NSString *)@"iOSRE SaveToDisk!",localPath);
    UISaveVideoAtPathToSavedPhotosAlbum(localPath, nil, nil, nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"已成功保存到相册！" message:nil delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

%new
- (void)SLSightCopyUrl
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    WCMediaItem *media = [self SLSightDataItem];
    pasteboard.string = media.dataUrl.url;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"已成功复制到粘贴板！" message:nil delegate:self cancelButtonTitle:@"OK!" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

%new
- (void)SLRetweetSight
{
    SightMomentEditViewController *editSightVC = [[%c(SightMomentEditViewController) alloc] init];
    NSString *localPath = [[self SLSightDataItem] pathForSightData];
    UIImage *image = [[self valueForKey:@"_sightView"] getImage];
    [editSightVC setRealMoviePath:localPath];
    [editSightVC setMoviePath:localPath];
    [editSightVC setRealThumbImage:image];
    [editSightVC setThumbImage:image];
    [WCTimelineVC presentViewController:editSightVC animated:YES completion:^{

    }];
}

%new
- (void)SLSightSendToFriends
{
    [self sendSightToFriend];
}


- (void)onLongTouch
{
    %log((NSString *)@"IOSRE,start build menu!");
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController.isMenuVisible) return;//防止出现menu闪屏的情况
    [self becomeFirstResponder];
    //%log((NSString *)@"IOSRE,continue build menu！");
    NSString *localPath = [[self SLSightDataItem] pathForSightData];
    %log((NSString *)@"GET PATH SUCCESS",localPath);
    BOOL isExist =[[NSFileManager defaultManager] fileExistsAtPath:localPath];
    //BOOL isExist = YES;
    UIMenuItem *retweetMenuItem = [[UIMenuItem alloc] initWithTitle:@"朋友圈" action:@selector(SLRetweetSight)];
    UIMenuItem *saveToDiskMenuItem = [[UIMenuItem alloc] initWithTitle:@"保存到相册" action:@selector(SLSightSaveToDisk)];
    UIMenuItem *sendToFriendsMenuItem = [[UIMenuItem alloc] initWithTitle:@"好友" action:@selector(SLSightSendToFriends)];
    UIMenuItem *copyURLMenuItem = [[UIMenuItem alloc] initWithTitle:@"复制链接" action:@selector(SLSightCopyUrl)];
    if(isExist){
        [menuController setMenuItems:@[retweetMenuItem,sendToFriendsMenuItem,saveToDiskMenuItem,copyURLMenuItem]];
    }else{
        [menuController setMenuItems:@[copyURLMenuItem]];
    }
    [menuController setTargetRect:CGRectZero inView:self];
    [menuController setMenuVisible:YES animated:YES];
    %log((NSString *)@"IOSRE FINISH TOUCH!");
}
%end

%hook SightMomentEditViewController

- (void)popSelf
{
    [self dismissViewControllerAnimated:YES completion:^{

    }];
}

%end