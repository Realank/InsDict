//
//  ViewController.m
//  InsDict
//
//  Created by Realank on 2017/5/9.
//  Copyright © 2017年 Realank. All rights reserved.
//

#import "ViewController.h"
#import "WordModel.h"

#define TRIM(str) [(str) stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *translateLabel;
@property (weak, nonatomic) IBOutlet UITextField *originalTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self resetLabel];
    [_originalTextField becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged) name:UITextFieldTextDidChangeNotification object:nil];
    [WordModel translateWord:@"a" whenComplete:^(WordModel *word) {
        NSLog(@"%@", word);
    }];
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
    _translateLabel.text = @"即时辞典";
}

- (void)translate:(NSString*)string{
    __weak typeof(self) weakSelf = self;
    [WordModel translateWord:TRIM(string) whenComplete:^(WordModel *word) {
        if (word) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (weakSelf.originalTextField.text.length == 0) {
                    [weakSelf resetLabel];
                }else{
                    weakSelf.translateLabel.text = [word.translatedWord copy];
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
