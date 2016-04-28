//
//  NRCityPickerView.m
//  Pods
//
//  Created by 聂锐 on 16/4/27.
//
//

#import "NRCityPickerView.h"

@implementation NRCityPickerView {
    NSInteger _provinceIndex;
    NSInteger _cityIndex;
    NSInteger _districtIndex;
    NSDictionary *_selectProvinceDictionary;
    NSDictionary *_selectionCityDictionary;
    NSDictionary *_selectDistrictDictionary;
    NSArray *_selectCityArray;
    NSArray *_selectDistrictAray;
    NSArray *_provincesArray;
    NSArray *_citiesArray;
    NSArray *_districtsArray;
    /**
     *  是否是自治区
     */
    BOOL _isAutonomous;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
        [self loadData];
    }
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor whiteColor];
    _cityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 220)];
    _cityPicker.backgroundColor = [UIColor clearColor];
    _cityPicker.delegate = self;
    _cityPicker.dataSource = self;
    [self addSubview:_cityPicker];
    
    _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sureButton.frame = CGRectMake(0, _cityPicker.bounds.size.height, self.bounds.size.width, 45);
    _sureButton.backgroundColor = [UIColor clearColor];
    [_sureButton setTitle:NSLocalizedString(@"确定", nil) forState:UIControlStateNormal];
    [_sureButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_sureButton addTarget:self action:@selector(sureButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_sureButton];
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        _provinceIndex = row;
        _cityIndex = 0;
        _districtIndex = 0;
        _selectProvinceDictionary = [self.chinaArray objectAtIndex:_provinceIndex];
    } else if (component == 1) {
        _cityIndex = row;
        _districtIndex = 0;
    } else if (component == 2) {
        _districtIndex = row;
    }
    [self initCitties];
    [pickerView reloadAllComponents];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.chinaArray.count;
    } else if (component == 1) {
        return _selectCityArray.count;
    } else if (component == 2) {
        return _selectDistrictAray.count;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        NSDictionary *province = [self.chinaArray objectAtIndex:row];
        _province = [province objectForKey:@"name"];
        return _province;
    } else if (component == 1) {
        NSDictionary *city = [_selectCityArray objectAtIndex:row];
        _city = [city objectForKey:@"name"];
        return _city;
    } else if (component ==2) {
        NSDictionary *district = [_selectDistrictAray objectAtIndex:row];
        _district = [district objectForKey:@"name"];
        return _district;
    }
    return nil;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label = (UILabel *)view;
    if (!label) {
        label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentCenter;
    }
    label.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return label;
}


- (void)loadData {
    NSString *Path = [[NSBundle mainBundle] pathForResource:@"region" ofType:@"plist"];
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:Path];
    NSDictionary *root = [data objectForKey:@"root"];
    self.chinaArray = [root objectForKey:@"province"];
    _cityIndex = 0;
    _provinceIndex = 0;
    _districtIndex = 0;
    [self initCitties];
}

- (void)initCitties {
    _selectProvinceDictionary = [self.chinaArray objectAtIndex:_provinceIndex];
    id city = [_selectProvinceDictionary objectForKey:@"city"];
    if ([city isKindOfClass:[NSArray class]]) {
        _isAutonomous = NO;
        _selectCityArray = [_selectProvinceDictionary objectForKey:@"city"];
        _selectionCityDictionary = [_selectCityArray objectAtIndex:_cityIndex];
        _selectDistrictAray = [_selectionCityDictionary objectForKey:@"district"];
        _selectDistrictDictionary = [_selectDistrictAray objectAtIndex:_districtIndex];
        _postCode = [_selectDistrictDictionary objectForKey:@"zipcode"];
    } else if ([city isKindOfClass:[NSDictionary class]]) {
        _isAutonomous = YES;
        _selectionCityDictionary = [_selectProvinceDictionary objectForKey:@"city"];
        _selectCityArray = [_selectionCityDictionary objectForKey:@"district"];
        NSDictionary *district = [_selectCityArray objectAtIndex:_cityIndex];
        _postCode = [district objectForKey:@"zipcode"];
        _selectDistrictDictionary = nil;
        _selectDistrictAray = nil;
    }

}

- (void)updateIndex {
    NSMutableArray *province = [[NSMutableArray alloc] initWithCapacity:self.chinaArray.count];
    [_chinaArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dict = (NSDictionary *)obj;
        NSString *name = [dict objectForKey:@"name"];
        if (name.length) {
            [province addObject:name];
        }
    }];
    _provincesArray = [NSArray arrayWithArray:province];
    if ([_provincesArray containsObject:_province]) {
        _provinceIndex = [_provincesArray indexOfObject:_province];
    }
    _selectProvinceDictionary = [self.chinaArray objectAtIndex:_provinceIndex];
    id city = [_selectProvinceDictionary objectForKey:@"city"];
    if ([city isKindOfClass:[NSArray class]]) {
        _isAutonomous = NO;
        _selectCityArray = [_selectProvinceDictionary objectForKey:@"city"];
        NSMutableArray *city = [[NSMutableArray alloc] initWithCapacity:_selectCityArray.count];
        [_selectCityArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dic = (NSDictionary *)obj;
            NSString *str = [dic objectForKey:@"name"];
            if (str.length) {
                [city addObject:str];
            }
        }];
        _citiesArray = [NSArray arrayWithArray:city];
        if ([_citiesArray containsObject:_city]) {
            _cityIndex = [_citiesArray indexOfObject:_city];
        }
        
        _selectionCityDictionary = [_selectCityArray objectAtIndex:_cityIndex];
        _selectDistrictAray = [_selectionCityDictionary objectForKey:@"district"];
        NSMutableArray *district = [NSMutableArray arrayWithCapacity:_selectDistrictAray.count];
        [_selectDistrictAray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dic = (NSDictionary *)obj;
            NSString *str = [dic objectForKey:@"name"];
            if (str.length) {
                [district addObject:str];
            }
        }];
        _districtsArray = [NSArray arrayWithArray:district];
        if ([_districtsArray containsObject:_district]) {
            _districtIndex = [_districtsArray indexOfObject:_district];
        } else {
            _districtIndex = 0;
        }
        _selectDistrictDictionary = [_selectDistrictAray objectAtIndex:_districtIndex];
        _postCode = [_selectDistrictDictionary objectForKey:@"zipcode"];
        [_cityPicker reloadAllComponents];
        [_cityPicker selectRow:_provinceIndex inComponent:0 animated:YES];
        [_cityPicker selectRow:_cityIndex inComponent:1 animated:YES];
        [_cityPicker selectRow:_districtIndex inComponent:2 animated:YES];
    } else if ([city isKindOfClass:[NSDictionary class]]) {
        _isAutonomous = YES;
        _selectionCityDictionary = [_selectProvinceDictionary objectForKey:@"city"];
        _selectCityArray = [_selectionCityDictionary objectForKey:@"district"];
        NSMutableArray *city = [NSMutableArray arrayWithCapacity:_selectDistrictAray.count];
        [_selectCityArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDictionary *dic = (NSDictionary *)obj;
            NSString *str = [dic objectForKey:@"name"];
            if (str.length) {
                [city addObject:str];
            }
        }];
        _citiesArray = [NSArray arrayWithArray:city];
        if ([_citiesArray containsObject:_city]) {
            _cityIndex = [_citiesArray indexOfObject:_city];
        }
        _districtIndex = 0;
        _districtsArray = nil;
        NSDictionary *district = [_selectCityArray objectAtIndex:_cityIndex];
        _postCode = [district objectForKey:@"zipcode"];
        _selectDistrictDictionary = nil;
        _selectDistrictAray = nil;
        [_cityPicker reloadAllComponents];
        [_cityPicker selectRow:_provinceIndex inComponent:0 animated:YES];
        [_cityPicker selectRow:_cityIndex inComponent:1 animated:YES];
    }
}

- (void)setProvince:(NSString *)province city:(NSString *)city district:(NSString *)district {
    _province = province;
    _city = city;
    _district = district.length > 0 ? district : @"";
    [self updateIndex];
}

- (void)sureButtonPressed:(id)sender {
    if (_isAutonomous) {
        _district = nil;
    }
    [self.delegate didCityPickerPickedWithProvice:_province city:_city district:_district postCode:_postCode];
}

@end
