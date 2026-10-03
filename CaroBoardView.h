#import <UIKit/UIKit.h>

@protocol CaroBoardDelegate <NSObject>
- (void)boardDidSelectRow:(NSInteger)row col:(NSInteger)col;
@end

@interface CaroBoardView : UIView

@property (nonatomic, weak) id<CaroBoardDelegate> delegate;
@property (nonatomic, assign) NSInteger lastRow;
@property (nonatomic, assign) NSInteger lastCol;
@property (nonatomic, strong) NSArray *winningLine; // Array of NSValue [row, col]

- (void)setPiece:(NSInteger)piece atRow:(NSInteger)row col:(NSInteger)col;
- (NSInteger)pieceAtRow:(NSInteger)row col:(NSInteger)col;
- (void)resetBoard;

@end
