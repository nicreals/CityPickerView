//
//  NRCityPickerView.h
//  Pods
//
//  Created by 聂锐 on 16/4/27.
//
//

#import <UIKit/UIKit.h>

@class NRCityPickerView;

@protocol NRCityPickerViewDelegate <NSObject>

- (void)didCityPickerPickedWithProvice:(NSString *)province city:(NSString *)city district:(NSString *)region postCode:(NSString *)postCode;

@end

@interface NRCityPickerView : UIView <UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView *cityPicker;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, weak) id<NRCityPickerViewDelegate> delegate;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, assign) NSString *district;
@property (nonatomic, strong) NSString *postCode;
@property (nonatomic, strong) NSArray *chinaArray;
- (void)setProvince:(NSString *)province city:(NSString *)city district:(NSString *)district;

@end
