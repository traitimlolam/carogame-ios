#import "CaroBoardView.h"

#define BOARD_SIZE 15

@implementation CaroBoardView {
    NSInteger _grid[BOARD_SIZE][BOARD_SIZE];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0.96 green:0.87 blue:0.70 alpha:1.0]; // Gỗ ấm sang trọng
        self.layer.cornerRadius = 12.0;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 2.0;
        self.layer.borderColor = [UIColor colorWithRed:0.55 green:0.40 blue:0.25 alpha:1.0].CGColor;
        [self resetBoard];
    }
    return self;
}

- (void)resetBoard {
    for (int r = 0; r < BOARD_SIZE; r++) {
        for (int c = 0; c < BOARD_SIZE; c++) {
            _grid[r][c] = 0;
        }
    }
    self.lastRow = -1;
    self.lastCol = -1;
    self.winningLine = nil;
    [self setNeedsDisplay];
}

- (void)setPiece:(NSInteger)piece atRow:(NSInteger)row col:(NSInteger)col {
    if (row >= 0 && row < BOARD_SIZE && col >= 0 && col < BOARD_SIZE) {
        _grid[row][col] = piece;
        self.lastRow = row;
        self.lastCol = col;
        [self setNeedsDisplay];
    }
}

- (NSInteger)pieceAtRow:(NSInteger)row col:(NSInteger)col {
    if (row >= 0 && row < BOARD_SIZE && col >= 0 && col < BOARD_SIZE) {
        return _grid[row][col];
    }
    return 0;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    CGFloat cellSize = w / (CGFloat)BOARD_SIZE;

    // 1. Vẽ các đường kẻ lưới
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0.45 green:0.32 blue:0.20 alpha:0.8].CGColor);
    CGContextSetLineWidth(ctx, 1.2);

    for (int i = 0; i < BOARD_SIZE; i++) {
        CGFloat x = cellSize * 0.5 + i * cellSize;
        CGContextMoveToPoint(ctx, x, cellSize * 0.5);
        CGContextAddLineToPoint(ctx, x, h - cellSize * 0.5);

        CGFloat y = cellSize * 0.5 + i * cellSize;
        CGContextMoveToPoint(ctx, cellSize * 0.5, y);
        CGContextAddLineToPoint(ctx, w - cellSize * 0.5, y);
    }
    CGContextStrokePath(ctx);

    // 2. Vẽ 5 điểm sao (Star points)
    NSInteger starIndices[3] = {3, 7, 11};
    CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.40 green:0.25 blue:0.15 alpha:1.0].CGColor);
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            CGFloat cx = cellSize * 0.5 + starIndices[i] * cellSize;
            CGFloat cy = cellSize * 0.5 + starIndices[j] * cellSize;
            CGContextFillEllipseInRect(ctx, CGRectMake(cx - 3.5, cy - 3.5, 7.0, 7.0));
        }
    }

    // 3. Vẽ quân cờ X và O
    for (int r = 0; r < BOARD_SIZE; r++) {
        for (int c = 0; c < BOARD_SIZE; c++) {
            NSInteger p = _grid[r][c];
            if (p == 0) continue;

            CGFloat cx = cellSize * 0.5 + c * cellSize;
            CGFloat cy = cellSize * 0.5 + r * cellSize;
            CGFloat radius = cellSize * 0.38;

            if (p == 1) {
                // Quân X: Đỏ rực sắc nét
                CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0.85 green:0.15 blue:0.15 alpha:1.0].CGColor);
                CGContextSetLineWidth(ctx, 3.2);
                CGContextSetLineCap(ctx, kCGLineCapRound);

                CGContextMoveToPoint(ctx, cx - radius, cy - radius);
                CGContextAddLineToPoint(ctx, cx + radius, cy + radius);
                CGContextMoveToPoint(ctx, cx + radius, cy - radius);
                CGContextAddLineToPoint(ctx, cx - radius, cy + radius);
                CGContextStrokePath(ctx);
            } else if (p == 2) {
                // Quân O: Xanh biển đậm thể thao
                CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:0.10 green:0.35 blue:0.85 alpha:1.0].CGColor);
                CGContextSetLineWidth(ctx, 3.2);
                CGContextStrokeEllipseInRect(ctx, CGRectMake(cx - radius, cy - radius, radius * 2, radius * 2));
            }

            // Đánh dấu nước đi cuối cùng
            if (r == self.lastRow && c == self.lastCol) {
                CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.2 green:0.8 blue:0.2 alpha:0.9].CGColor);
                CGContextFillEllipseInRect(ctx, CGRectMake(cx - 3.0, cy - 3.0, 6.0, 6.0));
            }
        }
    }

    // 4. Vẽ đường kẻ thắng cuộc
    if (self.winningLine && self.winningLine.count >= 2) {
        CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithRed:1.0 green:0.8 blue:0.0 alpha:0.85].CGColor);
        CGContextSetLineWidth(ctx, 6.0);
        CGContextSetLineCap(ctx, kCGLineCapRound);

        NSValue *firstVal = self.winningLine.firstObject;
        NSValue *lastVal = self.winningLine.lastObject;
        CGPoint p1 = [firstVal CGPointValue];
        CGPoint p2 = [lastVal CGPointValue];

        CGFloat x1 = cellSize * 0.5 + p1.y * cellSize;
        CGFloat y1 = cellSize * 0.5 + p1.x * cellSize;
        CGFloat x2 = cellSize * 0.5 + p2.y * cellSize;
        CGFloat y2 = cellSize * 0.5 + p2.x * cellSize;

        CGContextMoveToPoint(ctx, x1, y1);
        CGContextAddLineToPoint(ctx, x2, y2);
        CGContextStrokePath(ctx);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *t = [touches anyObject];
    CGPoint pt = [t locationInView:self];

    CGFloat w = self.bounds.size.width;
    CGFloat cellSize = w / (CGFloat)BOARD_SIZE;

    NSInteger col = (NSInteger)(pt.x / cellSize);
    NSInteger row = (NSInteger)(pt.y / cellSize);

    if (row >= 0 && row < BOARD_SIZE && col >= 0 && col < BOARD_SIZE) {
        if (_grid[row][col] == 0) {
            if ([self.delegate respondsToSelector:@selector(boardDidSelectRow:col:)]) {
                [self.delegate boardDidSelectRow:row col:col];
            }
        }
    }
}

@end
