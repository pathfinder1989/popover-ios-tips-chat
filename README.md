# popover-ios-tips-chat

### 使用方法


````

	UILabel *label = [UILabel new];
    label.text = @"发布入口在这儿";
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor blueColor];
    label.frame = CGRectMake(0, 0, 180, 50);
    
    MSPopoverView *popoverView = [[MSPopoverView alloc] initWithCustomView:label];
    popoverView.contentBgColor = [UIColor blackColor];
    [popoverView popoverAtView:sender inView:self.view animated:YES];

````