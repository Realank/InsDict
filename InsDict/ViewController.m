//
//  ViewController.m
//  InsDict
//
//  Created by Realank on 2017/5/9.
//  Copyright © 2017年 Realank. All rights reserved.
//

#import "ViewController.h"
#import "WordModel.h"

#define TimeCount 30 * 6
#define TRIM(str) [(str) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *translateLabel;
@property (weak, nonatomic) IBOutlet UITextField *originalTextField;
@property (assign, nonatomic) BOOL needWaitForSelection;
@property (assign, nonatomic) NSInteger timeLeft;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self resetLabel];
    [_originalTextField becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged) name:UITextFieldTextDidChangeNotification object:nil];
    CADisplayLink* link = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshTimer)];
    link.frameInterval = 2;
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)refreshTimer{
    if (_needWaitForSelection) {
        _timeLeft--;
        if (_timeLeft <= 0) {
            _needWaitForSelection = NO;
            //select all text
            [_originalTextField selectAll:nil];
        }
    }
}

- (void)textFieldChanged{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* string = _originalTextField.text;
        if (string.length) {
            [self translate:string];
        }else{
            [self resetLabel];
        }
        
    });
    
}

- (void)resetLabel{
    _needWaitForSelection = NO;
    _translateLabel.text = @"瞬间辞典";
}

- (void)fillLabel:(NSString*)text{
    _timeLeft = TimeCount;
    _needWaitForSelection = YES;
    _translateLabel.text = text;
}

- (void)translate:(NSString*)string{
    __weak typeof(self) weakSelf = self;
    [WordModel translateWord:TRIM(string) whenComplete:^(WordModel *word) {
        if (word) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.originalTextField.text.length == 0) {
                    [weakSelf resetLabel];
                }else{
                    [weakSelf fillLabel:[word.translatedWord copy]];
                }
                
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf resetLabel];
            });
        }
    }];
}

@end
