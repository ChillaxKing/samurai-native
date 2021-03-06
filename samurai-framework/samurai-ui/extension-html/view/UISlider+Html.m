//
//     ____    _                        __     _      _____
//    / ___\  /_\     /\/\    /\ /\    /__\   /_\     \_   \
//    \ \    //_\\   /    \  / / \ \  / \//  //_\\     / /\/
//  /\_\ \  /  _  \ / /\/\ \ \ \_/ / / _  \ /  _  \ /\/ /_
//  \____/  \_/ \_/ \/    \/  \___/  \/ \_/ \_/ \_/ \____/
//
//	Copyright Samurai development team and other contributors
//
//	http://www.samurai-framework.com
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

#import "UISlider+Html.h"

#import "_pragma_push.h"

#if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "Samurai_HtmlStyle.h"
#import "Samurai_HtmlRenderObject.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation UISlider(Html)

+ (HtmlRenderModel)html_defaultRenderModel
{
	return HtmlRenderModel_Element;
}

- (void)html_applyDom:(SamuraiHtmlDomNode *)dom
{
	[super html_applyDom:dom];

	NSString * isContinuous = [dom.domAttributes objectForKey:@"is-continuous"];
	NSString * value = [dom.domAttributes objectForKey:@"value"];
	NSString * minValue = [dom.domAttributes objectForKey:@"min-value"];
	NSString * maxValue = [dom.domAttributes objectForKey:@"max-value"];
	
	if ( value )
	{
		self.value = [value floatValue];
	}

	if ( minValue )
	{
		self.minimumValue = [minValue floatValue];
	}

	if ( maxValue )
	{
		self.maximumValue = [maxValue floatValue];
	}
	
	if ( isContinuous )
	{
		self.continuous = YES;
	}
	else
	{
		self.continuous = NO;
	}
}

- (void)html_applyStyle:(SamuraiHtmlStyle *)style
{
	[super html_applyStyle:style];

	UIColor * color = [style computeColor:self.thumbTintColor];

	self.minimumTrackTintColor = [color colorWithAlphaComponent:0.5f];
	self.maximumTrackTintColor = color;
	self.thumbTintColor = color;
}

- (void)html_applyFrame:(CGRect)newFrame
{
	[super html_applyFrame:newFrame];
}

- (void)html_forView:(UIView *)hostView
{
	if ( [hostView isKindOfClass:[UIScrollView class]] )
	{
		[hostView addObserver:self
				   forKeyPath:@"contentOffset"
					  options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew
					  context:(void *)hostView];
	}
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	NSObject * oldValue = [change objectForKey:@"old"];
	NSObject * newValue = [change objectForKey:@"new"];
	
	if ( newValue )
	{
		UIView * hostView = (__bridge UIView *)(context);
		
		if ( [hostView isKindOfClass:[UIScrollView class]] )
		{
			UIScrollView * scrollView = (UIScrollView *)hostView;
			
			if ( NO == CGSizeEqualToSize( scrollView.contentSize, CGSizeZero ) )
			{
				CGFloat width = 0;
				CGFloat offset = 0;
				
				CGFloat contentWidth = scrollView.contentSize.width;
				CGFloat contentHeight = scrollView.contentSize.height;
				
				CGFloat frameWidth = scrollView.frame.size.width;
				CGFloat frameHeight = scrollView.frame.size.height;
				
				if ( contentWidth > frameWidth && contentHeight <= frameHeight )
				{
					// horizontal
					
					width	= contentWidth - frameWidth;
					offset	= scrollView.contentOffset.x;
				}
				else if ( contentHeight > frameHeight && contentWidth <= frameWidth )
				{
					// vertical
					
					width	= contentHeight - frameHeight;
					offset	= scrollView.contentOffset.y;
				}
				else
				{
					width	= 0.0f;
					offset	= 0.0f;
				}
				
				self.minimumValue = 0.0f;
				self.maximumValue = 1.0f;
				
				[self setValue:(offset / width) animated:YES];
			}
			else
			{
				[self setValue:0.0f animated:YES];
			}
		}
	}
}

@end

// ----------------------------------
// Unit test
// ----------------------------------

#pragma mark -

#if __SAMURAI_TESTING__

TEST_CASE( UI, UISlider_Html )

DESCRIBE( before )
{
}

DESCRIBE( after )
{
}

TEST_CASE_END

#endif	// #if __SAMURAI_TESTING__

#endif	// #if (TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR)

#import "_pragma_pop.h"
