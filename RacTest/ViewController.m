//
//  ViewController.m
//  RacTest
//
//  Created by Miaoz on 2017/2/21.
//  Copyright © 2017年 Miaoz. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>



@interface ViewController ()<UIAlertViewDelegate>
@property (nonatomic,strong)UITextField *userNameFeild;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
   RACSignal *getRandomSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(arc4random())];
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];
    
    [getRandomSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [getRandomSignal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
//    [self racSignalLink];
    [self racSignalPass];
}
//* 1 RAC发送消息,并且绑定到控件
-(void)racSenderMessage {
    //延迟2.0S 发送"呵呵哒~"消息
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"呵呵哒"];
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"处理垃圾");
        }];
    }] delay:2.0];
//将_userNameFeild的`text`属性与映射后的信号量的值绑定到一起
    RAC(_userNameFeild , text) = [signal map:^id(id value) {
        if ([value isEqualToString:@"呵呵哒"]) {
            return @"么么哒";
        }
        return nil;
    }];

}
//* 2 RAC代理
-(void)racProtocolMothel {
    RACSignal *protocolSignal = [self rac_signalForSelector:@selector(alertView:clickedButtonAtIndex:) fromProtocol:@protocol(UIAlertViewDelegate)];
    [protocolSignal subscribeNext:^(id x) {
        NSLog(@"RAC代理协议-");
    }];
    
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
//        [self ];
        //执行代理方法
    });

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

}

//* 3 RAC通知
-(void)racNotification {
    //接受通知并且处理
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"RAC_Notifaciotn" object:nil] subscribeNext:^(id x) {
//          NSLog(@"notify.content = %@",notify.userInfo[@"content"]);
    }];
    
//发出通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RAC_Notifaciotn" object:nil userInfo:@{@"content" : @"i'm a notification"}];

}

//* 4 RAC信号拼接
-(void)racSignalLink {

    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(1)];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(2)];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
     RACSignal* concatSignal = [RACSignal concat:@[signal1,signal2]];
    [concatSignal subscribeNext:^(id value) {
        NSLog(@"RAC信号拼接------value = %@",value);
    }];
    //或者
//    [[signal1 concat:signal2] subscribeNext:^(id value) {
//          NSLog(@"RAC信号拼接------value = %@",value);
//    }];

}
//* 5 RAC信号合并
-(void)racSignalMerge {

    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"清纯妹子"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"性感妹子"];
        [subscriber sendCompleted];
        return  nil;
    }];
    //合并操作
    RACSignal* mergeSignal = [RACSignal merge:@[signal1,signal2]];
    [mergeSignal subscribeNext:^(id x) {
          NSLog(@"RAC信号合并------我喜欢： %@",x);
    }];
    //或者
//    [[signal1 merge:signal2] subscribeNext:^(id x) {
//         NSLog(@"RAC信号合并------我喜欢： %@",x);
//    }];
}
//* 6 RAC信号组合(取信号量的最后发送的对象)
-(void)racSignalCombine {
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"年轻"];
        [subscriber sendNext:@"清纯"];
        [subscriber sendCompleted];
        return nil;
    }];

    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"温柔"];
        [subscriber sendCompleted];
        return nil;
    }];

     //combineLatest 将数组中的信号量发出的最后一个object 组合到一起
    [[RACSignal combineLatest:@[signal1,signal2]] subscribeNext:^(id x) {
        RACTupleUnpack(NSString *signal1_Str, NSString *signal2_Str) = (RACTuple *)x;
         NSLog(@"RAC信号组合------我喜欢 %@的 %@的 妹子",signal1_Str,signal2_Str);
    }];
    
    //会注意收到 组合方法后还可以跟一个Block  /** + (RACSignal *)combineLatest:(id<NSFastEnumeration>)signals reduce:(id (^)())reduceBlock */
    /*
     reduce这个Block可以对组合后的信号量做处理
     */
    //我们还可以这样使用
   RACSignal * combineSignal =[RACSignal combineLatest:@[signal1,signal2] reduce:^(NSString *signal1_Str, NSString *signal2_Str){
        return [signal1_Str stringByAppendingString:signal2_Str];
    }];
    [combineSignal subscribeNext:^(id x) {
         NSLog(@"RAC信号组合(Reduce处理)------我喜欢 %@ 的妹子",x);
    }];

}

//* 6 RAC信号组合(取信号量的最开始发送的对象)
-(void)racSignalZIP {
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"年轻"];
        [subscriber sendNext:@"清纯"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"温柔"];
        [subscriber sendCompleted];
        
        return nil;
    }];
    
    [[RACSignal zip:@[signal1,signal2]] subscribeNext:^(id x) {
        RACTupleUnpack(NSString *signal1_Str, NSString *signal2_Str) = (RACTuple *)x;
         NSLog(@"RAC信号压缩------我喜欢 %@的 %@的 妹子",signal1_Str, signal2_Str);
    }];
}
//* 8 RAC信号过滤
-(void)racSignalFilter {
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@(19)];
        [subscriber sendNext:@(12)];
        [subscriber sendNext:@(20)];
        [subscriber sendCompleted];
        
        return nil;
    }] filter:^BOOL(id value) {
        NSNumber *numberValue = value;
        if(numberValue.integerValue < 18) {
            //18禁
            NSLog(@"RAC信号过滤------FBI Warning~");
        }
        return numberValue.integerValue > 18;
    }] subscribeNext:^(id x) {
         NSLog(@"RAC信号过滤------年龄：%@",x);
    }];
}
// 9 RAC信号传递
-(void)racSignalPass {
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"老板向我扔过来一个Star"];
        return nil;
    }] flattenMap:^RACStream *(id value) {
         NSLog(@"RAC信号传递flattenMap1------%@",value);
        RACSignal *tmpSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:[NSString stringWithFormat:@"%@----我向老板扔回一块板砖",value]];
            return nil;
        }];
        
        return tmpSignal;
    }] flattenMap:^RACStream *(id value) {
        NSLog(@"RAC信号传递flattenMap2------%@",value);
        
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:[NSString stringWithFormat:@"%@---我跟老板正面刚~,结果可想而知",value]];
            return nil;
        }];
    }] subscribeNext:^(id x) {
          NSLog(@"RAC信号传递last------%@",x);
    }];
}
//* 10 RAC信号串
//用那个著名的脑筋急转弯说明吧，“如何把大象放进冰箱里”  第一步，打开冰箱；第二步，把大象放进冰箱；第三步，关上冰箱门。
-(void)racSignalQueue {
    //与信号传递类似，不过使用 `then` 表明的是秩序，没有传递value
    [[[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
         NSLog(@"RAC信号串------打开冰箱");
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"RAC信号串------把大象放进冰箱");
            [subscriber sendCompleted];
            return nil;
        }];
    }] then:^RACSignal *{
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"RAC信号串------关上冰箱门");
            [subscriber sendCompleted];
            return nil;
        }];
    }] subscribeNext:^(id x) {
         NSLog(@"RAC信号串------Over");
    }];

}
//* 11 RAC_Command介绍
-(void)racCommandDemo {
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            NSLog(@"racCommandDemo------亲，帮我带份饭~");
            [subscriber sendCompleted];
            return nil;
        }];
    }];
//命令执行
    [command execute:nil];


}
//* 12 RACSignal 的一些修饰符
-(void)racSignalOther {
    //延迟
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"RAC信号延迟-----等等我~等等我2秒"];
        [subscriber sendCompleted];
        return nil;
    }] delay:2.0] subscribeNext:^(id x) {
          NSLog(@"RAC信号延迟-----终于等到你~");
    }];

    //定时任务，可以代替NSTimer,可以看到`RACScheduler`使用GCD实现的
    [[RACSignal interval:60*60 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
         NSLog(@"每小时吃一次药，不要放弃治疗");
    }];
    
    //设置超时时间
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:@"hh"];
            [subscriber sendCompleted];
            return nil;
        }] delay:4] subscribeNext:^(id x) {
            NSLog(@"RAC设置超时时间------请求到数据:%@",x);
            [subscriber sendNext:[@"RAC设置超时时间------请求到数据:" stringByAppendingString:x]];
            [subscriber sendCompleted];
        }];
         return nil;
    }] timeout:3 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        //在timeout规定时间之内接受到信号，才会执行订阅者的block
        //这这里3秒之内没有接受到信号，所有该次订阅已失效
        NSLog(@"请求到的数据:%@",x);
    }];
    
    //设置retry次数，这部分可以和网络请求一起用
    __block int retry_idx = 0;
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        if (retry_idx < 3) {
            retry_idx++;
            [subscriber sendError:nil];
        }else {
            [subscriber sendNext:@"success!"];
            [subscriber sendCompleted];
        }
        return nil;
    }] retry:3] subscribeNext:^(id x) {
        NSLog(@"请求:%@",x);
    }];
    
    //节流阀,throttle秒内只能通过1个消息
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"6"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"66"];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [subscriber sendNext:@"666"];
            [subscriber sendCompleted];
        });
        
        return nil;
    }] throttle:2] subscribeNext:^(id x) {
        //throttle: N   N秒之内只能通过一个消息，所以@"66"是不会被发出的
        NSLog(@"RAC_throttle------result = %@",x);
    }];

    //条件控制
    /**
     解释：`takeUntil:(RACSignal *)signalTrigger` 只有当`signalTrigger`这个signal发出消息才会停止
     */
    [[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            //每秒发一个消息
            [subscriber sendNext:@"RAC_Condition------吃饭中~"];
        }];
        return nil;
    }] takeUntil:[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //延迟3S发送一个消息，才会让前面的信号停止
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"RAC_Condition------吃饱了~");
            [subscriber sendNext:@"吃饱了"];
        });
        return nil;
    }]] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];

}





//networkSignal

//    RACSignal *networkSignal = [RACSignal createSignal:^RACDisposable *(id subscriber) {
//        NetworkOperation *operation = [NetworkOperation getJSONOperationForURL:@"http://someurl"];
//        [operation setCompletionBlockWithSuccess:^(NetworkOperation *theOperation, id *result) {
//            [subscriber sendNext:result];
//            [subscriber sendCompleted];
//        } failure:^(NetworkOperation *theOperation, NSError *error) {
//            [subscriber sendError:error];
//        }];

//几个立即可用的方式, 来从内置控制流机制中拉取信号:

//signals.m
//RACSignal *controlUpdate = [myButton rac_signalForControlEvents:UIControlEventTouchUpInside];
// signals for UIControl events send the control event value (UITextField, UIButton, UISlider, etc)
// subscribeNext:^(UIButton *button) { NSLog(@"%@", button); // UIButton instance }

//RACSignal *textChange = [myTextField rac_textSignal];
// some special methods are provided for commonly needed control event values off certain controls
// subscribeNext:^(UITextField *textfield) { NSLog(@"%@", textfield.text); // "Hello!" }

//RACSignal *alertButtonClicked = [myAlertView rac_buttonClickedSignal];
// signals for some delegate methods send the delegate params as the value
// e.g. UIAlertView, UIActionSheet, UIImagePickerControl, etc
// (limited to methods that return void)
// subscribeNext:^(NSNumber *buttonIndex) { NSLog(@"%@", buttonIndex); // "1" }

//RACSignal *viewAppeared = [self rac_signalForSelector:@selector(viewDidAppear:)];
// signals for arbitrary selectors that return void, send the method params as the value
// works for built in or your own methods
// subscribeNext:^(NSNumber *animated) { NSLog(@"viewDidAppear %@", animated); // "viewDidAppear 1" }


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
