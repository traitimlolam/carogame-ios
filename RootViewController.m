#import "RootViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#define BOARD_SIZE 15

@interface RootViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UISegmentedControl *modeControl;
@property (nonatomic, strong) CaroBoardView *boardView;
@property (nonatomic, strong) UIButton *resetButton;

@property (nonatomic, assign) NSInteger currentPlayer; // 1: X, 2: O
@property (nonatomic, assign) BOOL isGameOver;
@property (nonatomic, assign) NSInteger userScore;
@property (nonatomic, assign) NSInteger aiScore;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.12 green:0.12 blue:0.14 alpha:1.0]; // Dark mode cao cấp
    self.navigationController.navigationBarHidden = YES;

    self.currentPlayer = 1;
    self.isGameOver = NO;
    self.userScore = 0;
    self.aiScore = 0;

    [self setupUI];
}

- (void)setupUI {
    CGFloat viewW = self.view.bounds.size.width;
    CGFloat viewH = self.view.bounds.size.height;
    CGFloat safeTop = 55.0;

    // 1. Tiêu đề Cá Nhân Hóa
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, safeTop, viewW - 40, 36)];
    self.titleLabel.text = @"🏆 CỜ CARO • NGUYỄN TRỌNG HIẾU";
    self.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    self.titleLabel.textColor = [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0]; // Vàng hoàng gia
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.titleLabel];

    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, safeTop + 32, viewW - 40, 20)];
    subLabel.text = @"Bản Độc Quyền Dành Cho Chủ Xưởng (iOS 16 RootHide)";
    subLabel.font = [UIFont systemFontOfSize:12.0];
    subLabel.textColor = [UIColor lightGrayColor];
    subLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:subLabel];

    // 2. Chế độ chơi
    self.modeControl = [[UISegmentedControl alloc] initWithItems:@[@"🤖 Đấu Với Máy (AI)", @"👥 2 Người"]];
    self.modeControl.frame = CGRectMake(30, safeTop + 62, viewW - 60, 34);
    self.modeControl.selectedSegmentIndex = 0;
    self.modeControl.selectedSegmentTintColor = [UIColor colorWithRed:0.25 green:0.45 blue:0.9 alpha:1.0];
    [self.modeControl setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateSelected];
    [self.modeControl setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]} forState:UIControlStateNormal];
    [self.modeControl addTarget:self action:@selector(modeChanged) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.modeControl];

    // 3. Trạng thái & Điểm số
    self.statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, safeTop + 104, viewW - 40, 24)];
    self.statusLabel.text = @"Lượt: X (Bạn) - Chạm để đánh";
    self.statusLabel.font = [UIFont boldSystemFontOfSize:15.0];
    self.statusLabel.textColor = [UIColor whiteColor];
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.statusLabel];

    self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, safeTop + 128, viewW - 40, 20)];
    self.scoreLabel.text = @"Tỉ số: Bạn [ 0 ]  -  [ 0 ] Máy";
    self.scoreLabel.font = [UIFont systemFontOfSize:13.0];
    self.scoreLabel.textColor = [UIColor colorWithRed:0.7 green:0.8 blue:1.0 alpha:1.0];
    self.scoreLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.scoreLabel];

    // 4. Bàn cờ Caro 15x15
    CGFloat boardMargin = 16.0;
    CGFloat boardSize = viewW - boardMargin * 2;
    self.boardView = [[CaroBoardView alloc] initWithFrame:CGRectMake(boardMargin, safeTop + 158, boardSize, boardSize)];
    self.boardView.delegate = self;
    [self.view addSubview:self.boardView];

    // 5. Nút Ván Mới
    self.resetButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.resetButton.frame = CGRectMake(viewW * 0.5 - 90, safeTop + 170 + boardSize, 180, 44);
    [self.resetButton setTitle:@"🔄 VÁN MỚI" forState:UIControlStateNormal];
    self.resetButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    [self.resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.resetButton.backgroundColor = [UIColor colorWithRed:0.85 green:0.2 blue:0.2 alpha:1.0];
    self.resetButton.layer.cornerRadius = 22.0;
    self.resetButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.resetButton.layer.shadowOpacity = 0.4;
    self.resetButton.layer.shadowOffset = CGSizeMake(0, 3);
    [self.resetButton addTarget:self action:@selector(resetGame) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.resetButton];
}

- (void)modeChanged {
    [self resetGame];
}

- (void)resetGame {
    [self.boardView resetBoard];
    self.currentPlayer = 1;
    self.isGameOver = NO;
    self.statusLabel.text = @"Lượt: X (Bạn) - Chạm để đánh";
}

- (void)boardDidSelectRow:(NSInteger)row col:(NSInteger)col {
    if (self.isGameOver) return;

    // Rung phản hồi haptic
    UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [gen impactOccurred];

    // Đặt quân của người chơi
    [self.boardView setPiece:self.currentPlayer atRow:row col:col];

    NSArray *winLine = [self checkWinAtRow:row col:col piece:self.currentPlayer];
    if (winLine) {
        [self handleWinForPlayer:self.currentPlayer winLine:winLine];
        return;
    }

    // Chuyển lượt
    if (self.modeControl.selectedSegmentIndex == 0) {
        // Đấu với AI
        self.currentPlayer = 2;
        self.statusLabel.text = @"Máy đang suy nghĩ...";

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self makeAIMove];
        });
    } else {
        // 2 Người
        self.currentPlayer = (self.currentPlayer == 1) ? 2 : 1;
        NSString *playerText = (self.currentPlayer == 1) ? @"X (Người 1)" : @"O (Người 2)";
        self.statusLabel.text = [NSString stringWithFormat:@"Lượt: %@", playerText];
    }
}

// Thuật toán AI Caro thông minh: Đếm chuỗi điểm Công & Thủ
- (void)makeAIMove {
    if (self.isGameOver) return;

    NSInteger bestScore = -1;
    NSInteger bestR = -1;
    NSInteger bestC = -1;

    // Quét toàn bộ bàn cờ tìm điểm tối ưu
    for (int r = 0; r < BOARD_SIZE; r++) {
        for (int c = 0; c < BOARD_SIZE; c++) {
            if ([self.boardView pieceAtRow:r col:c] == 0) {
                // Điểm tấn công của máy (quân 2)
                NSInteger attackScore = [self evaluatePointAtRow:r col:c forPiece:2];
                // Điểm phòng ngự chặn người (quân 1)
                NSInteger defenseScore = [self evaluatePointAtRow:r col:c forPiece:1];

                NSInteger totalScore = attackScore + (NSInteger)(defenseScore * 1.15); // Ưu tiên phòng ngự chặn các thế hiểm
                if (totalScore > bestScore) {
                    bestScore = totalScore;
                    bestR = r;
                    bestC = c;
                }
            }
        }
    }

    if (bestR == -1) {
        bestR = 7; bestC = 7;
    }

    UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
    [gen impactOccurred];

    [self.boardView setPiece:2 atRow:bestR col:bestC];

    NSArray *winLine = [self checkWinAtRow:bestR col:bestC piece:2];
    if (winLine) {
        [self handleWinForPlayer:2 winLine:winLine];
        return;
    }

    self.currentPlayer = 1;
    self.statusLabel.text = @"Lượt: X (Bạn) - Chạm để đánh";
}

- (NSInteger)evaluatePointAtRow:(NSInteger)r col:(NSInteger)c forPiece:(NSInteger)piece {
    NSInteger score = 0;
    int dr[4] = {0, 1, 1, 1};
    int dc[4] = {1, 0, 1, -1};

    for (int i = 0; i < 4; i++) {
        int count = 1;
        // Đi tới
        for (int step = 1; step <= 4; step++) {
            int nr = (int)r + dr[i] * step;
            int nc = (int)c + dc[i] * step;
            if (nr >= 0 && nr < BOARD_SIZE && nc >= 0 && nc < BOARD_SIZE && [self.boardView pieceAtRow:nr col:nc] == piece) {
                count++;
            } else { break; }
        }
        // Đi lùi
        for (int step = 1; step <= 4; step++) {
            int nr = (int)r - dr[i] * step;
            int nc = (int)c - dc[i] * step;
            if (nr >= 0 && nr < BOARD_SIZE && nc >= 0 && nc < BOARD_SIZE && [self.boardView pieceAtRow:nr col:nc] == piece) {
                count++;
            } else { break; }
        }

        if (count >= 5) score += 100000;
        else if (count == 4) score += 10000;
        else if (count == 3) score += 1000;
        else if (count == 2) score += 100;
    }
    return score;
}

- (NSArray *)checkWinAtRow:(NSInteger)r col:(NSInteger)c piece:(NSInteger)piece {
    int dr[4] = {0, 1, 1, 1};
    int dc[4] = {1, 0, 1, -1};

    for (int i = 0; i < 4; i++) {
        NSMutableArray *line = [NSMutableArray array];
        [line addObject:[NSValue valueWithCGPoint:CGPointMake(r, c)]];

        // Lùi
        for (int step = 1; step < 5; step++) {
            int nr = (int)r - dr[i] * step;
            int nc = (int)c - dc[i] * step;
            if (nr >= 0 && nr < BOARD_SIZE && nc >= 0 && nc < BOARD_SIZE && [self.boardView pieceAtRow:nr col:nc] == piece) {
                [line insertObject:[NSValue valueWithCGPoint:CGPointMake(nr, nc)] atIndex:0];
            } else { break; }
        }
        // Tiến
        for (int step = 1; step < 5; step++) {
            int nr = (int)r + dr[i] * step;
            int nc = (int)c + dc[i] * step;
            if (nr >= 0 && nr < BOARD_SIZE && nc >= 0 && nc < BOARD_SIZE && [self.boardView pieceAtRow:nr col:nc] == piece) {
                [line addObject:[NSValue valueWithCGPoint:CGPointMake(nr, nc)]];
            } else { break; }
        }

        if (line.count >= 5) {
            return line;
        }
    }
    return nil;
}

- (void)handleWinForPlayer:(NSInteger)p winLine:(NSArray *)winLine {
    self.isGameOver = YES;
    self.boardView.winningLine = winLine;
    [self.boardView setNeedsDisplay];

    UINotificationFeedbackGenerator *gen = [[UINotificationFeedbackGenerator alloc] init];
    [gen notificationOccurred:UINotificationFeedbackTypeSuccess];

    if (p == 1) {
        self.userScore++;
        self.statusLabel.text = @"🎉 BẠN ĐÃ THẮNG! (5 QUÂN THÔNG)";
    } else {
        self.aiScore++;
        self.statusLabel.text = @"😢 MÁY THẮNG! HÃY THỬ LẠI";
    }

    self.scoreLabel.text = [NSString stringWithFormat:@"Tỉ số: Bạn [ %ld ]  -  [ %ld ] Máy", (long)self.userScore, (long)self.aiScore];
}

@end
